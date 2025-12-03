# Node.js Backend

##  Setup
```bash
git clone <repo-url>
cd backend
npm install
```

## .env 
Create `.env` in project root:
```
DATABASE_HOST=0.0.0.0
DATABASE_PORT=5432
DATABASE_NAME=playstation
DATABASE_USER=heso
DATABASE_PASSWORD=test

JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRE=7d

NODE_ENV=development
PORT=5000

ADMIN_EMAIL=admin@example.com
ADMIN_NAME=Administrator
```

## Create First Admin
```
npm run create-admin
```

## Run 
```
nodemon index.js
```
