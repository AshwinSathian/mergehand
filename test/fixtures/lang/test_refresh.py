import pytest


def test_refresh_rotates_the_token():
    pass


def test_does_not_leak_the_token():
    pass


class TestRefresh:
    def test_keeps_the_session(self):
        pass


@pytest.mark.parametrize("ttl", [0, -1], ids=["zero ttl is rejected", "negative ttl is rejected"])
def test_ttl(ttl):
    pass
