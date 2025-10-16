# Identity System Specification
## Three-Tier Verification with Outlier Support

---

## Philosophy

The **aequchain** identity system is designed to be:

- **Inclusive**: Everyone can participate, even without documents
- **Progressive**: Clear path from anonymous to verified
- **Privacy-Preserving**: Only hashes stored, never raw documents
- **Flexible**: Adapts to different jurisdictions and situations
- **Secure**: Prevents abuse while maintaining accessibility

---

## Three-Tier Structure

### Tier 0: Anonymous/Outlier

**Purpose**: Enable participation for those without traditional identity documents.

**Requirements**:
- Minimum 3 vouches from Tier 1+ members
- Total vouch strength ≥ 2.0
- No upfront documentation

**Capabilities**:
- Limited transactions (0.1% of treasury per 30 days)
- Rate limited (21 requests/minute, 233/day - Fibonacci)
- Can upload 5MB/day content (Fibonacci)
- Can create pledges and view jobs
- Can receive payments
- Can participate in equality

**Restrictions**:
- Cannot vouch for others
- Cannot register businesses
- Cannot create jobs or enterprises
- Limited API access

**Use Cases**:
- Refugees without documents
- People in transition
- Privacy advocates
- Testing the system
- Marginalized communities

### Tier 1: Documented

**Purpose**: Standard verified identity with full member capabilities.

**Requirements**:
- At least ONE of: National ID, Passport, Drivers License
- Document hash registered (never raw document)
- Optional biometric binding (device-local only)
- Jurisdiction declared

**Capabilities**:
- Standard transactions (1% of treasury per 30 days)
- Rate limited (89 requests/minute, 987/day - Fibonacci)
- Can upload 34MB/day content (Fibonacci)
- Can vouch for Tier 0 members (strength: 0.8)
- Can create jobs and pledges
- Full equality participation
- Can view all content

**Upgrade Path from Tier 0**:
1. Accumulate 3+ vouches (total strength ≥ 2.0)
2. Obtain valid identity document
3. Register document hash
4. Automatic upgrade to Tier 1

**Use Cases**:
- Regular members
- Most participants
- Individual contributors
- Job seekers
- Content creators

### Tier 2: Business/Organization

**Purpose**: Registered entities with enhanced capabilities.

**Requirements**:
- Business registration documents
- Tax identification
- At least one operating license
- Beneficial owners declared (linked Tier 1 accounts)
- Jurisdiction declared
- Contribution rate set (0-5%)

**Capabilities**:
- Enhanced transactions (5% of treasury per 30 days)
- Rate limited (233 requests/minute, 2584/day - Fibonacci)
- Can upload 144MB/day content (Fibonacci)
- Can vouch for Tier 0 members (strength: 1.0)
- Can create jobs, pledges, enterprises
- Set contribution rates
- Track internalization
- Multiple licenses

**Use Cases**:
- Businesses
- Cooperatives
- Non-profits
- Enterprise contributors
- Service providers

---

## Vouching System

### How Vouching Works

**Purpose**: Enable social trust to bootstrap identity for those without documents.

**Mechanics**:
1. Tier 1 or Tier 2 member vouches for Tier 0 member
2. Each voucher has daily limit: 3 vouches (Fibonacci)
3. Vouches have strength based on voucher tier:
   - Tier 1: strength = 0.8
   - Tier 2: strength = 1.0
4. Target needs 3 vouches with total strength ≥ 2.0
5. Vouches decay over 377 days (Fibonacci)

**Example Vouch Combinations**:
```
3 × Tier 1 vouches = 3 × 0.8 = 2.4 strength ✓ (qualified)
2 × Tier 2 vouches = 2 × 1.0 = 2.0 strength ✓ (qualified)
1 × Tier 2 + 2 × Tier 1 = 1.0 + 1.6 = 2.6 strength ✓ (qualified)
2 × Tier 1 vouches = 2 × 0.8 = 1.6 strength ✗ (not enough)
```

**Vouch Graph**:
```
Tier 2 (Business) ----vouch(1.0)----> Tier 0 (Outlier)
      |
      +--vouch(1.0)----> Tier 0 (Another)
      
Tier 1 (Member) ----vouch(0.8)----> Tier 0 (Outlier)
      |
      +--vouch(0.8)----> Tier 0 (Another)
      |
      +--vouch(0.8)----> Tier 0 (Third) [daily limit reached]
```

**Reputation Integration**:
- Vouch strength can be adjusted based on voucher reputation
- Bad vouchers lose reputation
- Good vouchers maintain or gain reputation
- System learns over time

### Anti-Abuse Measures

1. **Daily Limits**: Can't vouch more than 3 times per day (Fibonacci)
2. **Minimum Reputation**: Need 0.5 reputation to vouch
3. **Decay**: Vouches expire after 377 days (Fibonacci)
4. **Graph Analysis**: Detect vouch rings and collusion
5. **Penalties**: Bad vouches reduce reputation

---

## Document Registry

### Document Handling

**CRITICAL**: Never store raw documents. Only store:

```julia
struct DocumentHash
    doc_type::String        # e.g., "passport"
    hash::Hash              # SHA3-512 of document
    issuer_code::String     # e.g., "US" (ISO country)
    expiry::Union{Int64,Nothing}  # Unix timestamp or nothing
end
```

### Supported Document Types

**Personal Identity**:
- `national_id` - National ID card
- `passport` - International passport
- `drivers_license` - Driver's license
- `birth_certificate` - Birth certificate
- `residency_permit` - Residency or work permit

**Business Documents**:
- `business_registration` - Company registration
- `tax_id` - Tax identification
- `articles_of_incorporation` - Incorporation documents
- `partnership_agreement` - Partnership papers

**Licenses**:
- `operating_license` - General operating license
- `health_permit` - Health/food permits
- `professional_license` - Professional certifications
- `trade_license` - Trading permits
- `service_license` - Service industry licenses

### Document Verification

**Process**:
1. User scans/photographs document (local device)
2. Device computes SHA3-512 hash
3. Hash transmitted to blockchain (never raw document)
4. Blockchain stores hash + metadata
5. Document remains with user

**Verification Later**:
1. User presents document
2. Hash recomputed
3. Compared to stored hash
4. Match = verified

**Privacy Benefits**:
- No central document database
- Can't be hacked (no data to steal)
- User controls original
- Jurisdiction-specific rules apply
- Right to deletion simple (remove hash)

### Expiry Tracking

```
if document.expiry !== nothing:
    grace_period = 13 days (Fibonacci)
    warn_at = expiry - grace_period
    invalid_at = expiry
    
    if now >= warn_at and now < invalid_at:
        display_warning("Document expiring soon")
    
    if now >= invalid_at:
        mark_invalid()
        notify_resubmit()
```

---

## Biometric Binding (Optional)

### Device-Local Only

**PRINCIPLE**: Biometric data NEVER leaves the device.

**Implementation**:
```
Device Side:
1. User enrolls fingerprint/face (stays on device)
2. Device computes: template_hash = hash(biometric_template)
3. Device computes: commitment = hash(template_hash)
4. Device sends ONLY commitment to blockchain

Blockchain Side:
- Stores: hash(hash(template)) = commitment
- Never sees actual biometric data
- Never sees even the template hash

Verification:
1. User presents biometric to device
2. Device checks locally (never transmits)
3. Device signs assertion: "biometric verified"
4. Blockchain trusts device signature
```

**Benefits**:
- Biometric database breach impossible (no database)
- Privacy-compliant (GDPR, BIPA, etc.)
- User controls data
- Still prevents account sharing
- Device binding adds security

**Renewal**: Every 89 days (Fibonacci), re-verify biometric locally.

---

## Rate Limiting

### Per-Tier Limits (Fibonacci-Based)

| Tier | Requests/Minute | Requests/Day | Treasury % | Content MB/Day |
|------|----------------|--------------|------------|----------------|
| 0    | 21             | 233          | 0.1%       | 5              |
| 1    | 89             | 987          | 1.0%       | 34             |
| 2    | 233            | 2584         | 5.0%       | 144            |

### Implementation

```julia
function check_rate_limit(account_id, tier)
    limits = get_tier_limits(tier)
    
    minute_count = count_requests_last_60s(account_id)
    if minute_count >= limits.requests_per_minute
        return false  # Rate limited
    end
    
    day_count = count_requests_last_24h(account_id)
    if day_count >= limits.requests_per_day
        return false  # Daily limit reached
    end
    
    record_request(account_id)
    return true  # Allowed
end
```

---

## Business Registration

### Registration Process

1. **Prepare Documents**:
   - Business registration certificate
   - Tax identification
   - Operating licenses
   - Beneficial owner IDs

2. **Submit Hashes**:
   ```julia
   register_business!(
       registry,
       account_id,
       business_name,
       document_hashes,  # Array of DocumentHash
       licenses,          # Array of LicenseRecord
       beneficial_owners, # Array of AccountID
       jurisdiction,
       contribution_rate  # 0.0 to 0.05
   )
   ```

3. **Verification**:
   - Check all documents valid
   - Verify beneficial owners exist (Tier 1)
   - Validate licenses not expired
   - Confirm contribution rate ≤ 5%

4. **Approval**:
   - Business account created
   - Tier 2 status granted
   - Enhanced capabilities enabled

### License Management

```julia
struct LicenseRecord
    license_type::String          # e.g., "health_permit"
    license_hash::Hash            # Hash of license document
    issuing_authority::String     # e.g., "NYC Health Dept"
    valid_from::Int64            # Start date
    valid_until::Int64           # Expiry date
end
```

**Automatic Checks**:
- Warn 13 days before expiry (Fibonacci)
- Invalidate on expiry
- Require renewal
- Business status depends on valid licenses

---

## Jurisdiction Configuration

### Per-Jurisdiction Settings

```toml
[jurisdictions.US]
required_documents = ["tax_id", "business_registration"]
required_licenses = ["operating_license"]
contribution_reporting = true
kyc_level = "standard"

[jurisdictions.EU]
required_documents = ["vat_number", "company_registration"]
required_licenses = ["operating_license"]
gdpr_compliance = true
kyc_level = "enhanced"

[jurisdictions.DEMO]
required_documents = []
required_licenses = []
kyc_level = "none"
demo_mode = true
```

### Flexible Framework

- Each jurisdiction can specify requirements
- System adapts to local laws
- Clear path to compliance
- Future-proof for new jurisdictions

---

## API Endpoints

### Account Creation

```
POST /api/account/create
Body: {
  "tier": 0,  // 0, 1, or 2
  "name": "User Name",
  "jurisdiction": "US",
  "document_hashes": [],  // For Tier 1+
  "voucher_ids": ["id1", "id2", "id3"]  // For Tier 0
}
```

### Vouch for Another

```
POST /api/identity/vouch
Body: {
  "voucher_id": "my_account",
  "target_id": "tier0_account"
}
```

### Upgrade Tier

```
POST /api/identity/upgrade
Body: {
  "account_id": "my_account",
  "new_tier": 1,
  "document_hashes": [...]
}
```

### Register Business

```
POST /api/enterprises/register
Body: {
  "owner": "my_tier1_account",
  "business_name": "My Company",
  "contribution_rate": 0.03,
  "registration_hashes": [...],
  "licenses": [...]
}
```

---

## Security Considerations

### Threat Model

1. **Sybil Attacks**: Multiple fake identities
   - **Mitigation**: Vouch requirements, PoP integration

2. **Document Forgery**: Fake documents
   - **Mitigation**: Hash only (can't verify fake), real verification out-of-band

3. **Vouch Collusion**: Fake vouch rings
   - **Mitigation**: Graph analysis, reputation penalties

4. **Identity Theft**: Stolen credentials
   - **Mitigation**: Biometric binding, device binding

5. **Privacy Breach**: Document leaks
   - **Mitigation**: Never store raw documents, only hashes

---

## Implementation Files

- `/aequchain/files/src/types/IdentityTypes.jl` - Type definitions
- `/aequchain/files/src/identity/IdentityTiers.jl` - Tier management
- `/aequchain/files/src/identity/SocialVouching.jl` - Vouching system
- `/aequchain/files/src/identity/DocumentRegistry.jl` - Document handling
- `/aequchain/files/src/identity/BusinessRegistry.jl` - Business entities
- `/aequchain/files/configs/identity.toml` - Configuration

---

**Status**: Foundation complete, ready for integration with onboarding UI.
