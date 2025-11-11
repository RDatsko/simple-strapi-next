# simple-strapi-next
This is a Strapi and NextJS website template designed to be simple to use and work with without getting lost.

The structure of the site is to make the site URLs highly customizable while also making the use of te Content Type Layouts for slices.

Also, rather than have multiple folders, all the "folders" are structured in the "src/app/pages" folder.

"index.tsx" refers to the home page.  All other files are in the format where a folder's "/" in the URL is replaced by an "_".  This means that a url that contains for example, "/company/about-us" will have the file company_about-us.tsx.  This file file contains the location in Strapi of the file:

```
export const page="/###";
```

