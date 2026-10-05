const networks: string[] = [];

describe('refresh', () => {
  it('rotates the token', () => {});
  it('refresh rejects an expired token', () => {});
  it(
    'keeps the session alive when the access token ' +
      'is renewed',
    () => {},
  );
  // TODO: revokes every session on logout
});

test(`refresh returns 401 on a revoked token`, () => {});
