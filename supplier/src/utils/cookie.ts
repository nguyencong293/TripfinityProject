// Simple client-side cookie helpers (cannot remove HttpOnly cookies set by server)
export const deleteCookie = (name: string, path: string = "/") => {
  try {
    document.cookie = `${encodeURIComponent(
      name
    )}=; Path=${path}; Expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=Lax`;
    document.cookie = `${encodeURIComponent(
      name
    )}=; Expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=Lax`;
  } catch {
    // ignore
  }
};

export const deleteAllCookies = () => {
  try {
    const cookies = document.cookie.split(/; */);
    if (!cookies[0]) return;
    for (const c of cookies) {
      const eqPos = c.indexOf("=");
      const name = eqPos > -1 ? c.substring(0, eqPos) : c;
      deleteCookie(name.trim());
    }
  } catch {
    // ignore
  }
};
