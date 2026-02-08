# Requirements Document

## Introduction

This document outlines the requirements for transforming the existing single-page campaign creation form into a multi-step form with dynamic biodata fields. The System shall fetch biodata field definitions from the backend API and render them dynamically based on field type, while organizing the form into logical steps for better user experience.

## Glossary

- **Campaign Creation Form**: The user interface where users create flatmate/flat search campaigns
- **Biodata Fields**: Personal information fields (gender, date of birth, religion, tribe, marital status, occupation, income range) fetched dynamically from the backend
- **Multi-Step Form**: A form divided into multiple sequential pages/steps with navigation controls
- **MiscService**: The API service responsible for fetching data field definitions from the backend
- **DataField Model**: The data structure representing a field definition from the backend API
- **CreateCampaignController**: The controller managing campaign creation state and logic
- **Step Indicator**: Visual component showing current progress through form steps

## Requirements

### Requirement 1

**User Story:** As a user creating a campaign, I want the form to be organized into logical steps, so that I can focus on one section at a time without feeling overwhelmed.

#### Acceptance Criteria

1. WHEN THE User navigates to the campaign creation screen, THE Campaign Creation Form SHALL display Step 1 (Basic Information) as the initial view
2. THE Campaign Creation Form SHALL display a step indicator showing the current step number and total steps
3. WHEN THE User completes required fields in the current step, THE Campaign Creation Form SHALL enable the "Next" button
4. WHEN THE User clicks the "Next" button, THE Campaign Creation Form SHALL navigate to the subsequent step
5. WHEN THE User is on Step 2 or later, THE Campaign Creation Form SHALL display a "Back" button to return to the previous step

### Requirement 2

**User Story:** As a user, I want my personal biodata to be collected during campaign creation, so that potential flatmates can see relevant information about me.

#### Acceptance Criteria

1. WHEN THE Campaign Creation Form initializes, THE CreateCampaignController SHALL fetch biodata field definitions from the `/misc/datafields/biodata` endpoint
2. THE Campaign Creation Form SHALL display a dedicated Biodata step (Step 2) containing all fetched biodata fields
3. WHEN a biodata field has `fieldDataType` of "select", THE Campaign Creation Form SHALL render a dropdown with options from the field's `value` property split by comma
4. WHEN a biodata field has `fieldDataType` of "date", THE Campaign Creation Form SHALL render a date picker
5. WHEN a biodata field has `fieldDataType` of "text", THE Campaign Creation Form SHALL render a text input field
6. WHEN a biodata field has `isRequired` set to true, THE Campaign Creation Form SHALL mark the field as required and prevent step progression until filled
7. WHEN THE User submits the campaign, THE CreateCampaignController SHALL include all biodata values in the campaign payload under a `biodata` object with field `skey` as keys

### Requirement 3

**User Story:** As a developer, I want biodata fields to be fetched dynamically from the API, so that field definitions can be updated without code changes.

#### Acceptance Criteria

1. THE MiscService SHALL provide a method to fetch data fields by category name
2. WHEN THE MiscService fetches biodata fields, THE MiscService SHALL make a GET request to `/misc/datafields/biodata`
3. THE MiscService SHALL parse the API response into a list of DataField model instances
4. THE DataField Model SHALL contain properties: id, fieldCategoryId, skey, value, name, description, fieldDataType, isJsonValue, isRequired, sortOrder, createdAt
5. WHEN THE API request fails, THE MiscService SHALL handle the error gracefully and return an empty list

### Requirement 4

**User Story:** As a user, I want to see my progress through the form steps, so that I know how much of the form remains to be completed.

#### Acceptance Criteria

1. THE Campaign Creation Form SHALL display a progress indicator at the top showing all steps
2. THE Step Indicator SHALL visually distinguish between completed steps, current step, and upcoming steps
3. WHEN THE User navigates between steps, THE Step Indicator SHALL update to reflect the current position
4. THE Campaign Creation Form SHALL organize fields into three steps: Basic Info, Biodata, and Preferences

### Requirement 5

**User Story:** As a user, I want form validation to occur per step, so that I can correct errors before proceeding to the next step.

#### Acceptance Criteria

1. WHEN THE User attempts to proceed to the next step, THE Campaign Creation Form SHALL validate all required fields in the current step
2. WHEN validation fails, THE Campaign Creation Form SHALL display error messages for invalid fields
3. WHEN validation fails, THE Campaign Creation Form SHALL prevent navigation to the next step
4. THE Campaign Creation Form SHALL allow navigation back to previous steps without validation
5. WHEN THE User is on the final step and clicks submit, THE Campaign Creation Form SHALL validate all steps before submitting

### Requirement 6

**User Story:** As a user, I want the budget fields to display formatted numbers with commas, so that large amounts are easier to read.

#### Acceptance Criteria

1. WHEN THE User types in budget fields, THE Campaign Creation Form SHALL automatically format the input with thousand separators (commas)
2. WHEN THE User submits the campaign, THE CreateCampaignController SHALL remove commas from budget values before sending to the API
3. THE Campaign Creation Form SHALL accept only numeric input in budget fields
4. THE Campaign Creation Form SHALL maintain cursor position appropriately during formatting

### Requirement 7

**User Story:** As a user, I want to provide optional preferences for my ideal flatmate or apartment, so that I can find better matches.

#### Acceptance Criteria

1. THE Campaign Creation Form SHALL display preferences in Step 3 (Preferences)
2. WHEN THE User selects "Flatmate" as the goal, THE Campaign Creation Form SHALL display flatmate personality trait preference fields
3. WHEN THE User selects "Flat" as the goal, THE Campaign Creation Form SHALL display apartment preference fields
4. THE Campaign Creation Form SHALL mark all preference fields as optional
5. WHEN THE User submits with empty preference fields, THE CreateCampaignController SHALL exclude empty preference objects from the API payload
