from flask_app import app
from models import Claim, Session
from models.claim_status import ClaimStatus


@app.route("/claims/<protocol>/active")
def active_claims(protocol):
    with Session() as s:
        claim = Claim.get_active_claim_by_protocol(s, protocol)

        if claim is None:
            return {"ok": True, "data": None}

        claim_status = ClaimStatus.get_claim_status(s, claim.id)

    return {"ok": True, "data": {**claim.to_dict(), "resources_link": claim.resources_link if claim.id != 3 else None , "status": [{**status.to_dict()} for status in claim_status]}}
