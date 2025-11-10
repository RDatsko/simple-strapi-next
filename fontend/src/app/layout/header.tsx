export default function Header({ type }: { type: string }) {
  switch (type) {
    case "transparent":
      return <TransparentHeader />;
    case "white":
      return <WhiteHeader />;
    default:
      return <DefaultHeader />;
  }
}

/* ---------- Header Variants ---------- */

function TransparentHeader() {
  return (
    <header
      style={{
        background: "rgba(255,255,255,0.2)",
        padding: "1rem",
        color: "black",
      }}
    >
      <h3>Transparent Header</h3>
    </header>
  );
}

function WhiteHeader() {
  return (
    <header
      style={{
        background: "white",
        padding: "1rem",
        borderBottom: "1px solid #ccc",
        color: "black",
      }}
    >
      <h3>White Header</h3>
    </header>
  );
}

function DefaultHeader() {
  return (
    <header
      style={{
        background: "#f3f3f3",
        padding: "1rem",
        borderBottom: "1px solid #ddd",
      }}
    >
      <h3>Default Header</h3>
    </header>
  );
}