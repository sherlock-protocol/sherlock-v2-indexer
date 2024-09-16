import settings
from flask_app import app
from models import Protocol, ProtocolPremium, Session
from models.protocol_coverage import ProtocolCoverage


def get_protocol_metadata(bytes_id):
    return next(filter(lambda m: m["id"] == bytes_id, settings.PROTOCOLS_CSV), {})


class dummy:
    def to_dict(*x,):
        return {}

@app.route("/protocols")
def get_protocols():
    with Session() as s:
        protocols = (
            s.query(Protocol, ProtocolPremium)
            .join(ProtocolPremium, isouter=True)
            .distinct(Protocol.id)
            .order_by(
                Protocol.id,
                ProtocolPremium.premium_set_at.desc(),
            )
            .all()
        )
        protocols, premiums = zip(*protocols) if len(protocols) > 0 else ((), ())
        # Return empty class for protocol without premium
        premiums = [dummy() if p is None else p for p in premiums]
        coverages = [ProtocolCoverage.get_protocol_coverages(s, protocol.id) for protocol in protocols]
    return {
        "ok": True,
        "data": [
            {
                **get_protocol_metadata(protocol.bytes_identifier),
                **protocol.to_dict(),
                **premium.to_dict(),
                "coverages": [{**coverage.to_dict()} for coverage in coverages],
            }
            for premium, protocol, coverages in zip(premiums, protocols, coverages)
        ],
    }
