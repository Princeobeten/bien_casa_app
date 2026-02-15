# Testing Campaign API Endpoints

Ways to test all campaign endpoints implemented in `lib/app/services/api/campaign_service.dart`.

---

## 1. Test from the app (manual)

You must be **logged in**. Base URL is from your `.env` (`BASE_API_URL`), e.g. `https://your-api.up.railway.app/api/`. All requests need `Authorization: Bearer <access_token>` (DioClient adds this).

| Endpoint | How to trigger in the app |
|----------|---------------------------|
| **POST** `/campaign/create/step1` | Flatmate → Create campaign → Step 1 (basic info) → submit |
| **PUT** `/campaign/create/step2` | Create campaign → Step 2 (homeowner details) |
| **PUT** `/campaign/create/step3` | Create campaign → Step 3 (personality preferences) |
| **PUT** `/campaign/create/step4` | Create campaign → Step 4 (apartment preferences, non‑homeowner) |
| **POST** `/campaign/create/initiatePublishCampaign` | Create campaign → Step 5 (pay N1,000 to publish) |
| **GET** `/campaign/{id}` | Open a campaign detail (when wired to `CampaignService.getCampaign(id)`) |
| **DELETE** `/campaign/{id}` | My campaigns → delete a campaign |
| **GET** `/campaign/data/{step}/{id}` | (Wire in “Edit draft” or “Review step” to call `getCampaignStepData`) |
| **GET** `/campaign/all` | Flatmate tab → list of campaigns (fetch) |
| **GET** `/campaign/nearby` | (Wire “Near me” to `getNearbyCampaigns(lat, lng)`) |
| **GET** `/campaign/user/my-campaigns` | My campaigns tab |
| **GET** `/campaign/user/unpublished` | (Wire “Drafts” to `getUnpublishedCampaigns()`) |
| **POST** `/campaign/join` | Tap “Apply” on a campaign (needs payment reference) |
| **GET** `/campaign/{id}/flatmate-requests` | As campaign owner, open “Requests” for a campaign |
| **GET** `/campaign/my-requests/all` | (Wire “My requests” to `getMyFlatmateRequests()`) |
| **PUT** `/campaign/flatmate-request/{id}/view` | Owner marks a request as viewed |
| **PUT** `/campaign/flatmate-request/status` | Owner accepts/declines a request |
| **PUT** `/campaign/flatmate-request/{id}/withdraw` | User withdraws own request |
| **POST** `/campaign/house/add` | Add house to campaign (when wired) |
| **DELETE** `/campaign/house/{id}` | Remove house from campaign |
| **PUT** `/campaign/house/approve` | Owner approves/disapproves a house |
| **POST** `/campaign/{id}/create-chat` | Create group chat for campaign (when wired) |
| **POST** `/campaign/{id}/recommendations` | Get house recommendations (when wired) |

---

## 2. Test with Postman / Insomnia / curl

1. **Get a token**  
   Log in via the app or call your login API, then copy the `accessToken` (or equivalent) from the response or from app storage.

2. **Set base URL and auth**  
   - Base URL: e.g. `https://bien-casa-be-mvp-production.up.railway.app/api`  
   - Header: `Authorization: Bearer <your_access_token>`  
   - Header: `Content-Type: application/json`

3. **Call each endpoint** (paths are relative to base URL):

| Method | Path | Body (JSON) / query |
|--------|------|---------------------|
| POST | `/campaign/create/step1` | `{"maxFlatmates":2,"city":"Lagos","budget":{"min":100000,"max":500000,"plan":"month"},"creatorIsHomeOwner":false}` |
| PUT | `/campaign/create/step2` | `{"campaignId":1,"district":"Lekki","city":"Lagos","location":"VI","creatorHouseFeatures":{"bedrooms":3}}` |
| PUT | `/campaign/create/step3` | `{"campaignId":1,"matePersonalityTraitPreference":{"smoking":"No","pets":"Allowed"}}` |
| PUT | `/campaign/create/step4` | `{"campaignId":1,"apartmentPreference":{"bedrooms":2,"furnished":true}}` |
| POST | `/campaign/create/initiatePublishCampaign` | `{"campaignId":1,"paymentMethod":"wallet","walletPin":"1234"}` or with `biometric`, `deviceId`, `signature`, `nonce`, `timestamp` |
| GET | `/campaign/1` | — |
| DELETE | `/campaign/1` | — |
| GET | `/campaign/data/step1/1` | — |
| GET | `/campaign/all` | Query: `page=1`, `limit=20`, optional `status`, `city`, `budgetMin`, `budgetMax`, etc. |
| GET | `/campaign/nearby` | Query: `latitude=6.5244`, `longitude=3.3792`, `radius=50` |
| GET | `/campaign/user/my-campaigns` | Query: `page=1`, `limit=20` |
| GET | `/campaign/user/unpublished` | Query: `page=1`, `limit=20` |
| POST | `/campaign/join` | `{"campaignId":1,"paymentReference":"PAY_xyz123"}` |
| GET | `/campaign/1/flatmate-requests` | Query: `page=1`, `limit=20`, optional `status`, `isViewed` |
| GET | `/campaign/my-requests/all` | — |
| PUT | `/campaign/flatmate-request/1/view` | — |
| PUT | `/campaign/flatmate-request/status` | `{"requestId":1,"status":"Matched","note":"Welcome"}` |
| PUT | `/campaign/flatmate-request/1/withdraw` | — |
| POST | `/campaign/house/add` | `{"campaignId":1,"houseLeaseId":5}` |
| DELETE | `/campaign/house/1` | — |
| PUT | `/campaign/house/approve` | `{"campaignHouseId":1,"isApproved":true}` |
| POST | `/campaign/1/create-chat` | — |
| POST | `/campaign/1/recommendations` | — |

Replace `1` in paths with real IDs from your backend.

---

## 3. Quick curl examples

```bash
# Set your token and base URL
export TOKEN="your_access_token_here"
export BASE="https://bien-casa-be-mvp-production.up.railway.app/api"

# Get all campaigns
curl -s -H "Authorization: Bearer $TOKEN" "$BASE/campaign/all?page=1&limit=5"

# Get my campaigns
curl -s -H "Authorization: Bearer $TOKEN" "$BASE/campaign/user/my-campaigns?page=1&limit=5"

# Get draft campaigns
curl -s -H "Authorization: Bearer $TOKEN" "$BASE/campaign/user/unpublished?page=1&limit=5"

# Get single campaign (replace 1 with real id)
curl -s -H "Authorization: Bearer $TOKEN" "$BASE/campaign/1"

# Get step1 data for campaign (replace 1 with real id)
curl -s -H "Authorization: Bearer $TOKEN" "$BASE/campaign/data/step1/1"

# Create campaign step 1
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"maxFlatmates":2,"city":"Lagos","budget":{"min":100000,"max":500000,"plan":"month"},"creatorIsHomeOwner":false}' \
  "$BASE/campaign/create/step1"
```

---

## 4. Optional: run a single “smoke” test from the app

Add a **debug-only** button (e.g. on profile or flatmate screen) that:

1. Calls a few read endpoints: `getAllCampaigns()`, `getMyCampaigns()`, `getUnpublishedCampaigns()`.
2. Prints or shows the response (e.g. `debugPrint` or a snackbar with “Campaigns: OK” / error).

That verifies auth and that the service hits the right endpoints without writing a full test suite. Remove or hide the button in release builds.

---

## Summary

- **In app:** Use the table in section 1 to trigger each endpoint from the UI.  
- **Outside app:** Use section 2 (Postman) or section 3 (curl) with a valid `Bearer` token and the base URL from your env.  
- **Quick check:** Use section 4 (optional debug button) to smoke-test a few GETs from the app.
