# IsoDock Website

Static website source for **https://isodock.vercel.app**.

The website is kept under `website/` so it stays isolated from the IsoDock application/runtime source.

## Logo quality

The site references the full-resolution project artwork at `/branding/isodock-icon-master.png` for the navbar, hero, footer, favicon, and touch icon. This avoids enlarging small favicon-sized raster assets and keeps the visible logo sharp.

## Deployment

This is plain static HTML with no build step. Deploy the repository root so `/branding/isodock-icon-master.png` is available to the site.
