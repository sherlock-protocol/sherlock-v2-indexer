import json
import logging
from typing import List, Optional, Tuple

from attr import define

from settings import WEB3_WSS
from utils import requests_retry_session

from .strategies import Strategies, Strategy

logger = logging.getLogger(__name__)


@define
class CustomYield:
    strategy: Strategy

    def get_apy(self, block: int, timestamp: int) -> Optional[float]:
        """Fetch the APY at a given block/timestamp.

        Args:
            block (int): Block number
            timestamp (int): UNIX timestamp

        Raises:
            NotImplementedError: This method must be overriden by children

        Returns:
            float: APY in number format (e.g. 0.035 for 3.5%)
        """
        raise NotImplementedError()


class MapleYield(CustomYield):
    pool_address = "0x6f6c8013f639979c84b756c7fc1500eb5af18dc4"  # Maven11 USDC Pool

    def get_apy(self, block: int, timestamp: int) -> Optional[float]:
        try:
            r = requests_retry_session()

            # Bypass CloudFlare until a more suitable adapter will be developed
            r.headers.update(
                {
                    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36",  # noqa
                    "Origin": "https://app.maple.finance",
                    "apollographql-client-name": "WebApp",
                    "apollographql-client-version": "1.0",
                    "accept": "*/*",
                    "accept-language": "en-GB,en-US;q=0.9,en;q=0.8",
                    "cache-control": "no-cache",
                    "content-type": "application/json",
                    "pragma": "no-cache",
                    "sec-ch-ua": 'Not;A Brand";v="99", "Google Chrome";v="97", "Chromium";v="97',
                    "sec-ch-ua-mobile": "70",
                    "sec-ch-ua-platform": "macOS",
                    "sec-fetch-dest": "empty",
                    "sec-fetch-mode": "cors",
                    "sec-fetch-site": "same-site",
                }
            )

            res = r.post(
                "https://api.maple.finance/v1/graphql",
                r"""
                {
                    "query":"query PoolData {  results: pool(contractAddress: \"%s\") {\n    lendingApy\n  }\n}\n",
                    "variables":null,
                    "operationName":"PoolData"
                }
                """
                % self.pool_address,
            ).json()

            # APY is returned as a string, for example "583" representing 5.83%
            apy = int(res["data"]["results"]["lendingApy"]) / 100 / 100
            logger.debug("Maple APY is %s" % apy)

            return apy

        except Exception as e:
            logger.exception(e)
            return None


class TrueFiYield(CustomYield):
    pool_address: str = "0xA991356d261fbaF194463aF6DF8f0464F8f1c742"  # TrueFi V2 USDC Pool

    def get_curve_y_apy(self) -> float:
        try:
            return requests_retry_session().get("https://stats.curve.fi/raw-stats/apys.json").json()["apy"]["day"]["y"]
        except Exception as e:
            logger.exception(e)
            return 0.0

    def get_pool_values(self, block: int) -> Tuple[float, float]:
        try:
            POOL_WSS = WEB3_WSS.eth.contract(
                address=self.pool_address,
                abi=json.loads(
                    """
                    [
                        {
                            "inputs": [],
                            "name": "poolValue",
                            "outputs": [
                            {
                                "internalType": "uint256",
                                "name": "",
                                "type": "uint256"
                            }
                            ],
                            "stateMutability": "view",
                            "type": "function"
                        },
                        {
                            "inputs": [],
                            "name": "strategyValue",
                            "outputs": [
                            {
                                "internalType": "uint256",
                                "name": "",
                                "type": "uint256"
                            }
                            ],
                            "stateMutability": "view",
                            "type": "function"
                        }
                    ]
                    """
                ),
            )
            pool_value = POOL_WSS.functions.poolValue().call(block_identifier=block)
            strategy_value = POOL_WSS.functions.strategyValue().call(block_identifier=block)

            return (pool_value, strategy_value)
        except Exception as e:
            logger.exception(e)
            return 0.0

    def get_loans(self) -> List[Tuple[int, int]]:
        """Fetch loans from the USDC pool, as a list of tuples of (loan amount, loan APY)"""
        r = requests_retry_session()
        r.headers.update(
            {
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36",  # noqa
                "Origin": "https://app.truefi.io/",
                "apollographql-client-name": "WebApp",
                "apollographql-client-version": "1.0",
                "accept": "*/*",
                "accept-language": "en-GB,en-US;q=0.9,en;q=0.8",
                "cache-control": "no-cache",
                "content-type": "application/json",
                "pragma": "no-cache",
                "sec-ch-ua": 'Not;A Brand";v="99", "Google Chrome";v="97", "Chromium";v="97',
                "sec-ch-ua-mobile": "70",
                "sec-ch-ua-platform": "macOS",
                "sec-fetch-dest": "empty",
                "sec-fetch-mode": "cors",
                "sec-fetch-site": "same-site",
            }
        )

        res = r.post(
            "https://api.thegraph.com/subgraphs/name/mikemccready/truefi-legacy",
            r"""
                {
                    "query":"query Loans {  loans(first: 1000, where: {status_in: [1, 2], poolAddress: \"%s\"} \n) {\n    APY\n amount\n term\n  }\n}\n",
                    "variables":null,
                    "operationName":"Loans"
                }
                """  # noqa
            % self.pool_address,
        ).json()["data"]["loans"]

        return [(int(item["amount"]), int(item["APY"]) / 10000) for item in res]

    def get_apy(self, block: int, timestamp: int) -> Optional[float]:
        try:
            (pool_value, strategy_value) = self.get_pool_values(block)
            logger.debug("TrueFi Pool value: %s" % pool_value)
            logger.debug("TrueFi Strategy value: %s" % strategy_value)

            crv_apy = self.get_curve_y_apy()
            logger.debug("CRV Y-POOL APY: %s" % crv_apy)

            crv_weighted_apy = strategy_value * crv_apy
            logger.debug("CRV Weighted APY: %s" % crv_weighted_apy)

            loans = self.get_loans()
            sum = 0
            weighted_apy = 0
            for item in loans:
                # item[0] = amount
                # item[1] = APY
                # TODO: Make use of the `term` to compute the actual value of this loan,
                # but ALL subgraphs available for TrueFi return term = 0 for all loans
                # They are fetching the `term` from each `LoanToken` contract.
                weighted_apy += item[0] * item[1]
                sum += item[0]
            # weighted_apy /= sum

            weighted_apy = (weighted_apy + crv_weighted_apy) / pool_value

            logger.debug("TrueFi Weighted APY: %s" % weighted_apy)

            return weighted_apy
        except Exception as e:
            logger.exception(e)
            return None


CUSTOM_YIELDS: List[CustomYield] = [MapleYield(Strategies.MAPLE), TrueFiYield(Strategies.TRUEFI)]


if __name__ == "__main__":
    apy = MapleYield(Strategies.TRUEFI).get_apy(14878797, 1)
    print("Maple APY %s" % apy)

    apy = TrueFiYield(Strategies.TRUEFI.address).get_apy(14878797, 1)
    print("TrueFI APY %s" % apy)
