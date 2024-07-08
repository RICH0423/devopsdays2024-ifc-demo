const express = require('express');

/**
 * @klotho::execution_unit {
 *   id = "user-service"
 * }
 */
const app = express();
app.use(express.json());

/* @klotho::persist {
 *   id = "user-db"
 * }
 */
const userDB = new Map();

async function addUser(req, res) {
  const {name, email} = req.body;
  try {
    await userDB.set(email, name);
    res.send(`Added username: ${name} and email: ${email}`);
  } catch (error) {
    res.status(500).json({message: error.message});
  }
}


async function getAllUsers(req, res) {
  try {
    res.json(Object.fromEntries(await userDB.entries()));
  } catch (error) {
    res.status(500).json({message: error.message});
  }
}

app.get('/users', getAllUsers);
app.post('/users', addUser);

/*
 * @klotho::expose {
 *  id = "user-api"
 *  target = "public"
 *  description = "Exposes the User API to the internet"
 * }
 */
app.listen(3000, () => console.log('App listening locally on: 3000'));
