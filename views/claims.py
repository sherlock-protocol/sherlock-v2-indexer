from flask_app import app
from models import Claim, Session


@app.route("/claims/<protocol>/active")
def active_claims(protocol):
    with Session() as s:
        claim = Claim.get_active_claim_by_protocol(s, protocol)

    if claim is None:
        return {"ok": True, "data": None}

    return {"ok": True, "data": claim.to_dict()}
