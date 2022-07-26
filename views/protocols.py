import settings
from flask_app import app
from models import Protocol, ProtocolPremium, Session
from models.protocol_coverage import ProtocolCoverage


def get_protocol_metadata(bytes_id):
    return next(filter(lambda m: m["id"] == bytes_id, settings.PROTOCOLS_CSV), {})


@app.route("/protocols")
def get_protocols():
    with Session() as s:
        protocols = (
            s.query(ProtocolPremium, Protocol)
            .join(Protocol, Protocol.id == ProtocolPremium.protocol_id)
            .distinct(ProtocolPremium.protocol_id)
            .order_by(
                ProtocolPremium.protocol_id,
                ProtocolPremium.premium_set_at.desc(),
            )
            .all()
        )

        premiums, protocols = zip(*protocols) if len(protocols) > 0 else ((), ())
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
