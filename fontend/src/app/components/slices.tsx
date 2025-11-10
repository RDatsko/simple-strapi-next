"use client";

interface RenderSlicesProps {
  slices?: any[];
  pageData?: Record<string, any>;
}

export default function RenderSlices({ slices, pageData }: RenderSlicesProps) {
  if (!slices || !Array.isArray(slices)) return null;

  const { Slices, ...restPageData } = pageData || {};

  return (
    <>
      {slices.map((slice) => {
        const componentName = slice.__component;
        if (!componentName) return null;

        try {
          // e.g. "page.component" → "./page/component"
          const componentPath = `./${componentName.replace(/\./g, "/")}`;
          const SliceComponent = require(`${componentPath}`).default;

          return <SliceComponent
            key={`${componentName}-${slice.id}`}
            {...slice}
            Slices={slices}
            pageData={restPageData}
          />;
        } catch (err) {
          console.warn(`⚠️ Missing slice component: ${componentName}`, err);
          return (
            <div
              key={`${componentName}-${slice.id}`}
              style={{ color: "gray", padding: "0.5rem", margin: "0.5rem", backgroundColor: "#eee", border: "1px solid #ddd" }}
            >
              Unknown slice: {componentName}
            </div>
          );
        }
      })}
    </>
  );
}
