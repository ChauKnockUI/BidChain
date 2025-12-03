const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();
const User = require('../src/models/User');
const { ethers } = require('ethers');

async function initAdmin() {
    try {
        // Connect to MongoDB
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected to MongoDB');

        // Check if admin already exists
        const existingAdmin = await User.findOne({ role: 'ADMIN' });
        if (existingAdmin) {
            console.log('Admin user already exists:', existingAdmin.username);
            process.exit(0);
        }

        // Generate wallet for admin
        const wallet = ethers.Wallet.createRandom();
        const adminUsername = 'admin1';
        const adminEmail = 'admin1@bidchain.local';
        const adminPassword = '12345678';

        // Hash password
        const salt = await bcrypt.genSalt(10);
        const passwordHash = await bcrypt.hash(adminPassword, salt);

        // Create admin user
        const adminUser = new User({
            username: adminUsername,
            email: adminEmail,
            password_hash: passwordHash,
            full_name: 'BidChain Admin',
            role: 'ADMIN',
            status: 'ACTIVE',
            wallet_address: wallet.address,
            encrypted_private_key: wallet.privateKey,
            avatar: null,
            country: 'Vietnam',
            city: 'Ho Chi Minh City',
            district: 'District 1',
            address: 'Admin Address',
            bio: 'BidChain System Administrator',
            balance_eth: '0',
            locked_eth: '0'
        });

        await adminUser.save();
        console.log('✅ Admin user created successfully!');
        console.log('Username:', adminUsername);
        console.log('Email:', adminEmail);
        console.log('Password:', adminPassword);
        console.log('Wallet Address:', wallet.address);

        process.exit(0);
    } catch (error) {
        console.error('❌ Error initializing admin:', error.message);
        process.exit(1);
    }
}

initAdmin();
