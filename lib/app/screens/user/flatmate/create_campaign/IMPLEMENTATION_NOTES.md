# Create Campaign Implementation

## Active Implementation: Stepped Create Campaign Page

**File:** `stepped_create_campaign_page.dart`

**Route:** `AppRoutes.ADD_FLATMATE` → `/add-flatmate`

### Navigation Points
The stepped create campaign page is accessed from:
1. **FloatingAddButton** - Floating action button on flatmate screen
2. **My Campaign Tab (Empty State)** - "Create Campaign" button when user has no campaigns
3. **My Campaign Tab (With Campaigns)** - "Create New" button when user has existing campaigns

### Form Steps

#### Step 1: Basic Information
Field order matches database schema:
- Campaign title (required)
- Goal (Flatmate/Flat/Short-stay)
- Budget range (with comma formatting, required)
- Budget plan (month/quarter/year)
- Max number of flatmates
- City/Town (required)
- Location (required)
- **I am a Home Owner** toggle
  - When enabled, shows inline:
    - Home district (optional)
    - Home city (optional)
    - Neighboring location (optional)
    - House features (multi-select chips)
    - Additional notes (optional)
- Accept requests toggle

**Removed fields:** Move date, Country

#### Step 2: Biodata
Dynamically fetched from API: `/misc/datafields/biodata`

Fields include:
- Gender (required, select)
- Date of Birth (required, date picker)
- Religion (optional, select)
- Tribe (optional, select)
- Marital Status (optional, select)
- Occupation (optional, text)
- Income Range (optional, select)

#### Step 3: Preferences
Conditional based on goal selection:
- **Flatmate Preferences** (if goal is "Flatmate")
  - Gender, religion, marital status, personality, habit
- **Apartment Preferences** (if goal is "Flat")
  - Type, aesthetic

**Note:** Home owner fields moved to Step 1

#### Step 4: Review
Summary of all entered information before submission

### UI Features
- **Circular progress indicator** on the right showing step progress
- **Step title** on the left (e.g., "Step 1 of 4 - Basic Info")
- Step-by-step validation
- Back/Next navigation
- Dynamic field generation from API
- Required field validation
- Date formatting with intl package
- Number formatting with comma separators

### API Integration
- Fetches biodata fields on initialization
- Submits campaign data to backend via `CampaignEnhancedController.createCampaign()`
- Validates required fields before submission
- Shows success/error messages via snackbar

## Legacy: Simple Create Campaign Page

**File:** `simple_create_campaign_page.dart`

Single-page form with all fields visible at once. Not currently in use but kept for reference.
