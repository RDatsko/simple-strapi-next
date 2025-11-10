import Header from "./layout/header";
import Footer from "./layout/footer";

export default function CustomNotFound() {
  const headerType = "white"; // or "white" / "transparent" if you want
  const locale = "en";

  return (
    <>
      <Header type={headerType} locale={locale} />
      <main style={{ padding: "4rem", textAlign: "center" }}>
        <h1 style={{ fontSize: "3rem", marginBottom: "1rem" }}>404</h1>
        <h2 style={{ marginBottom: "2rem" }}>Oops! Page not found.</h2>
        <p style={{ marginBottom: "2rem" }}>
          The page you are looking for doesn’t exist or has been moved.
        </p>
        <a
          href="/"
          style={{
            padding: "0.5rem 1rem",
            background: "#0070f3",
            color: "#fff",
            borderRadius: "0.25rem",
            textDecoration: "none",
          }}
        >
          Go Home
        </a>
      </main>
      <Footer type={headerType} locale={locale} />
    </>
  );
}