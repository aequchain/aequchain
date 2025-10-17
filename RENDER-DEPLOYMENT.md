# Deploying aequchain Testnet API to Render.com

## Prerequisites
- GitHub account
- Render.com account (free tier available)
- Your aequchain code pushed to GitHub

## Deployment Steps

### 1. Push Code to GitHub

First, commit and push the deployment files:

```bash
cd /home/ryan/code/UEB/aequchain
git add Dockerfile render.yaml start-api.jl
git commit -m "Add Render.com deployment configuration"
git push origin main
```

### 2. Deploy on Render.com

1. Go to [render.com](https://render.com) and sign up/log in
2. Click "New +" → "Web Service"
3. Connect your GitHub repository: `ttx89-dev/Universal-Equity-Blockchain`
4. Render will auto-detect the `render.yaml` file
5. Click "Apply" to use the configuration
6. Click "Create Web Service"

### 3. Get Your Live URL

Once deployed, Render will give you a URL like:
```
https://aequchain-testnet-api.onrender.com
```

### 4. Update the Flutter App

Update the API URL in the Flutter testnet app:

File: `/home/ryan/code/UEB/aequchain/aequchain_testnet_dapp/lib/main.dart`

Change:
```dart
final apiUrl = 'http://localhost:3000';
```

To:
```dart
final apiUrl = 'https://aequchain-testnet-api.onrender.com';
```

### 5. Rebuild and Deploy Testnet App

```bash
cd /home/ryan/code/UEB/aequchain/aequchain_testnet_dapp
flutter build web --base-href /testnet/
cp -r build/web "/home/ryan/code/UEB/Guide to Equidistributed Free Economy/efe/build/web/testnet"
cd "/home/ryan/code/UEB/Guide to Equidistributed Free Economy/efe/build/web"
git add testnet/
git commit -m "Update testnet to use live API"
git push origin master:main
```

## Configuration Details

### Environment Variables (Already Set in render.yaml)
- `PORT`: 10000 (Render's default)
- `JULIA_NUM_THREADS`: auto (for performance)

### Free Tier Limits
- 750 hours/month (enough for 24/7 operation)
- Spins down after 15 minutes of inactivity
- First request after spin-down takes ~30 seconds

### Health Check
The API includes a health endpoint at `/api/health` that Render uses to monitor the service.

## Alternative: Manual Render Setup (if render.yaml doesn't work)

If the auto-detection doesn't work, manually configure:

1. **Environment**: Docker
2. **Docker Command**: (leave empty, uses Dockerfile CMD)
3. **Plan**: Free
4. **Environment Variables**:
   - `PORT` = `10000`
   - `JULIA_NUM_THREADS` = `auto`
5. **Health Check Path**: `/api/health`

## Testing the Deployment

Once deployed, test with:

```bash
# Check health
curl https://YOUR-APP.onrender.com/api/health

# List accounts
curl https://YOUR-APP.onrender.com/api/testnet/accounts

# Create account
curl -X POST https://YOUR-APP.onrender.com/api/testnet/account/create \
  -H "Content-Type: application/json" \
  -d '{"account_id":"test","initial_balance":1000}'
```

## Monitoring

- View logs in Render dashboard
- Monitor uptime and performance
- Set up email alerts for downtime

## Cost

- **Free Tier**: Sufficient for testnet demo
- **Paid Options**: $7/month for always-on instance (no spin-down)

---

**Next Steps After Deployment:**
1. Get your live URL from Render
2. Update the Flutter app with the new API URL
3. Rebuild and redeploy the testnet
4. Test everything works
5. Optionally add a button to the guide later
