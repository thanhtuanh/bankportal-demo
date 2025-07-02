const fs = require('fs');
const path = require('path');

// Simple static build - copy files without Angular build
const distDir = 'dist/bank-portal';

// Create dist directory
if (!fs.existsSync(distDir)) {
    fs.mkdirSync(distDir, { recursive: true });
}

// Copy index.html
fs.copyFileSync('src/index.html', path.join(distDir, 'index.html'));

// Copy assets
if (fs.existsSync('src/assets')) {
    fs.cpSync('src/assets', path.join(distDir, 'assets'), { recursive: true });
}

console.log('✅ Static build completed');
