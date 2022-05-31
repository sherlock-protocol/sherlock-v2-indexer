import logging
from typing import List

from attr import define

from utils import requests_retry_session

from .strategies import Strategies

logger = logging.getLogger(__name__)


@define
class CustomYield:
    address: str

    def get_apy(self, block: int, timestamp: int) -> float:
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
    def get_apy(self, block: int, timestamp: int) -> float:
        # TODO: Check if strategy was deployed
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
                    "accept-encoding": "gzip, deflate, br",
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

            pool_address = "0x6f6c8013f639979c84b756c7fc1500eb5af18dc4"  # Maven11 USDC Pool

            res = r.post(
                "https://staging.api.maple.finance/v1/graphql",
                r"""
                {
                    "query":"query PoolData {  results: pool(contractAddress: \"%s\") {\n    lendingApy\n  }\n}\n",
                    "variables":null,
                    "operationName":"PoolData"
                }
                """
                % pool_address,
            ).json()

            # APY is returned as a string, for example "583" representing 5.83%
            apy = int(res["data"]["results"]["lendingApy"]) / 100 / 100
            logger.debug("Maple APY is %s" % apy)
            print("Maple APY = %s" % apy)

            return apy

        except Exception as e:
            logger.exception(e)
            return 0.0


class TrueFiYield(CustomYield):
    def get_apy(self, block: int, timestamp: int) -> float:
        # TODO: Check if strategy was deployed
        return 0.0


CUSTOM_YIELDS: List[CustomYield] = [MapleYield(Strategies.MAPLE.address), TrueFiYield(Strategies.TRUEFI.address)]


if __name__ == "__main__":
    for item in CUSTOM_YIELDS:
        item.get_apy(1, 2)
