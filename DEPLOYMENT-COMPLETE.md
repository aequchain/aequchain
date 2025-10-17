# aequchain Testnet Deployment Complete

## Summary

Successfully deployed the aequchain testnet Flutter app to GitHub Pages at `aequchain.github.io/testnet`.

## What Was Done

### 1. **Built the Testnet App for Web**
   - Built the Flutter testnet app with base href `/testnet/`
   - Command: `flutter build web --base-href /testnet/`
   - Location: `/home/ryan/code/UEB/aequchain/aequchain_testnet_dapp`

### 2. **Copied Testnet to GitHub Pages**
   - Copied the built testnet app to `aequchain.github.io/testnet/`
   - The testnet is now accessible at: **https://aequchain.github.io/testnet/**

### 3. **Updated the Guide App**
   - The guide app already had a button labeled "**aequchain TESTNET**" that links to `/testnet/`
   - Updated the guide's base href from `/guide/` to `/` (root)
   - Rebuilt and deployed the guide to the root of aequchain.github.io

### 4. **Committed and Pushed to GitHub**
   - Added all changes to git
   - Committed with message: "Add aequchain TESTNET at /testnet/ and update guide to root path"
   - Pushed to GitHub (master -> main branch)

## Live URLs

- **Guide**: https://aequchain.github.io/
- **Testnet**: https://aequchain.github.io/testnet/

## Directory Structure

```
aequchain.github.io/
├── index.html              # Guide homepage with testnet button
├── assets/                 # Guide assets
├── testnet/
│   ├── index.html         # Testnet app
│   ├── assets/            # Testnet assets
│   └── ...                # Other testnet files
└── ...                    # Other guide files
```

## Testing

To verify the deployment:

1. Visit https://aequchain.github.io/ - should show the guide with the "**aequchain TESTNET**" button
2. Click the button or visit https://aequchain.github.io/testnet/ directly - should load the testnet app
3. The testnet app should connect to your local backend at `http://localhost:3000` (as configured)

## Next Steps

If you want to use the testnet with a live backend:

1. Update the API URL in the testnet app to point to your production server
2. Rebuild and redeploy following the same steps above

## Source Code Locations

- **Guide source**: `/home/ryan/code/UEB/aequchain/guide_app/`
- **Testnet source**: `/home/ryan/code/UEB/aequchain/aequchain_testnet_dapp/`
- **Deployed site**: `/home/ryan/code/UEB/Guide to Equidistributed Free Economy/efe/build/web/`

---

**Deployment Date**: October 17, 2025
