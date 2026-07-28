# Deploying to GitHub and Cloudflare Pages

## 1. Create the GitHub repository

Create a public repository named:

`homelab-infrastructure-portfolio`

GitHub account:

`MadHub2024`

## 2. Upload from a Linux terminal

```bash
cd homelab-infrastructure-portfolio
git init
git branch -M main
git add .
git commit -m "Initial infrastructure portfolio"
git remote add origin https://github.com/MadHub2024/homelab-infrastructure-portfolio.git
git push -u origin main
```

GitHub may ask you to authenticate with a personal access token or through the browser.

## 3. Create the Cloudflare Pages project

In Cloudflare:

1. Open **Workers & Pages**.
2. Choose **Create application**.
3. Choose **Pages** and connect to Git.
4. Select `MadHub2024/homelab-infrastructure-portfolio`.
5. Use these build settings:
   - Framework preset: `None`
   - Build command: leave blank
   - Build output directory: `/`
6. Deploy.

## 4. Attach the custom domain

In the Pages project:

1. Open **Custom domains**.
2. Add `portfolio.dbservicessolutions.org`.
3. Follow Cloudflare's DNS prompt.
4. Wait for the certificate and deployment status to become active.

## 5. Future updates

```bash
git add .
git commit -m "Describe the change"
git push
```

Cloudflare Pages will automatically redeploy after each push.

## Recommended next edits

- Replace or supplement the text résumé with a polished PDF.
- Add sanitized screenshots.
- Add exported diagrams as SVG or PNG.
- Expand the case studies with dates, decisions, and measured outcomes.
- Add a privacy-conscious analytics solution only if needed.
