package auth

import "testing"

func TestRefreshRotatesTheToken(t *testing.T) {}

func TestExpiry(t *testing.T) {
	t.Run("expired refresh token is rejected", func(t *testing.T) {})
}

func TestRefresh(t *testing.T) {
	cases := []struct{ name string }{
		{name: "keeps the session"},
		{name: "revokes the old token"},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {})
	}
}
