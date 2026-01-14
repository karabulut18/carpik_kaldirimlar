# Future Implementation: Dynamic Social Previews (OG Tags)

**Goal**: When sharing a link like `https://.../post/123`, the social card (on Twitter, WhatsApp, LinkedIn) should show that specific post's **Title**, **Description**, and **Image**.

## The Problem
Currently, the app is a **Single Page Application (SPA)**.
1.  Social crawlers (bots) request the URL.
2.  Firebase Hosting returns the static `index.html`.
3.  The static HTML has generic tags ("Çarpık Kaldırımlar").
4.  Crawlers **do not execute JavaScript**, so they never see the Flutter app load the post data and change the title.

## The Solution: Cloud Functions (Server-Side)

We need to generate the `index.html` **on the server** before sending it to the bot.

### Implementation Steps

1.  **Initialize Cloud Functions**:
    ```bash
    firebase init functions
    ```
    (Choose JavaScript or TypeScript).

2.  **Create a Function (`generateMeta`)**:
    *   This function will:
        1.  Read the incoming URL path (e.g., `/post/{id}`).
        2.  Fetch the `Post` document from **Firestore Admin SDK**.
        3.  Read the original `index.html` template.
        4.  Replace the `<meta property="og:title" ...>` placeholders with the Post's data.
        5.  Send the modified HTML string as the response.

3.  **Update `firebase.json`**:
    *   Configure a **Rewrite** specifically for adding dynamic metadata.
    *   *Note*: Hosting Functions can be cached.

    ```json
    "hosting": {
      "rewrites": [
        {
          "source": "/post/**",
          "function": "generateMeta" // The name of your cloud function
        },
        {
          "source": "**",
          "destination": "/index.html"
        }
      ]
    }
    ```

### Alternative: Helmet / Meta SEO Packages
There are Flutter packages like `seo_renderer`, but they mostly help with search engines that *do* run some JS (like Google). They often fail for "dumb" crawlers (WhatsApp, iMessage). **Cloud Functions are the most robust solution.**

## Cost Implications 💰
To use Cloud Functions, your Firebase project must be on the **Blaze Plan** (Pay-as-you-go).
*   **Requirement**: You must link a Credit Card / Billing Account to Google Cloud.
*   **Free Tier**: The first **2 Million invocations per month are FREE**.
    *   This means you can have 2 million link shares/previews per month before paying a cent.
    *   Cost after free tier: ~$0.40 per million calls.
*   **Verdict**: For a startup/hobby app, this is effectively free, but requires the billing setup.
