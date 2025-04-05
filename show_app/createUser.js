require('dotenv').config();
const bcrypt = require('bcryptjs');
const db = require('./database');

// Liste des utilisateurs à créer
const users = [
  {
    email: 'admin@example.com',
    password: 'admin123'
  },
  {
    email: 'imaneouabderhem@gmail.com',
    password: 'imane2005'
  },
  // Ajoutez d'autres utilisateurs si nécessaire
  {
    email: 'user3@test.com',
    password: 'test123'
  }
];

console.log('Creating test users...');

// Fonction pour créer un utilisateur
const createUser = (user) => {
  return new Promise((resolve, reject) => {
    bcrypt.hash(user.password, 10, (err, hash) => {
      if (err) return reject(err);

      db.run(
        'INSERT INTO users (email, password) VALUES (?, ?)',
        [user.email, hash],
        function(err) {
          if (err) return reject(err);
          resolve(this.lastID);
        }
      );
    });
  });
};

// Création séquentielle des utilisateurs
(async () => {
  try {
    for (const user of users) {
      const userId = await createUser(user);
      console.log(`User created successfully with ID: ${userId}`);
      console.log(`Email: ${user.email}`);
      console.log(`Password: ${user.password}\n`);
    }
    console.log('All users created successfully!');
    process.exit(0);
  } catch (err) {
    console.error('Error creating users:', err.message);
    process.exit(1);
  }
})();