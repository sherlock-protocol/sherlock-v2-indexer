from flask_app import app
from models import Protocol, ProtocolPremium, Session
from models.protocol_coverage import ProtocolCoverage


@app.route("/protocols")
def get_protocols():
    with Session() as s:
        protocols = (
            s.query(ProtocolPremium, Protocol, ProtocolCoverage)
            .join(Protocol, Protocol.id == ProtocolPremium.protocol_id)
            .join(ProtocolCoverage, Protocol.id == ProtocolCoverage.protocol_id)
            .distinct(ProtocolPremium.protocol_id)
            .order_by(
                ProtocolPremium.protocol_id,
                ProtocolPremium.premium_set_at.desc(),
                ProtocolCoverage.coverage_amount_set_at.desc(),
            )
        )

    return {
        "ok": True,
        "data": [
            {**protocol.to_dict(), **premium.to_dict(), **coverage.to_dict()}
            for premium, protocol, coverage in protocols
        ],
    }
