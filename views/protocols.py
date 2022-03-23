from flask_app import app
from models import Protocol, ProtocolPremium, Session


@app.route("/protocols")
def get_protocols():
    with Session() as s:
        protocols = (
            s.query(ProtocolPremium, Protocol)
            .join(Protocol, Protocol.id == ProtocolPremium.protocol_id)
            .distinct(ProtocolPremium.protocol_id)
            .order_by(ProtocolPremium.protocol_id, ProtocolPremium.premium_set_at.desc())
        )

    return {"ok": True, "data": [{**protocol.to_dict(), **premium.to_dict()} for premium, protocol in protocols]}
