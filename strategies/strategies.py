from attrs import define


@define
class Strategy:
    address: str
    name: str


class Strategies:
    AAVE = Strategy(address="0x", name="Aave")
    COMPOUND = Strategy(address="0x", name="Compound")
    EULER = Strategy(address="0x", name="Euler")
    TRUEFI = Strategy(address="0x", name="TrueFi")
    MAPLE = Strategy(address="0x", name="Maple")

    ALL = [AAVE, COMPOUND, EULER, TRUEFI, MAPLE]
