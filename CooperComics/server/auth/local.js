const LocalStrategy = require('passport-local').Strategy;
const Administrador = require('../models/administrador');
const Cliente = require('../models/cliente');

module.exports = function localAuth(passport) {
	// LOCAL LOGIN
	passport.use('local-login', new LocalStrategy({
		usernameField: 'email',
		passwordField: 'password',
		passReqToCallback: true,
	}, (req, email, password, done) => {
		Cliente.findOne({
			email,
		}, (err, user) => {
			if (err) {
				return done(err);
			}

			if (!user) {
				Administrador.findOne({
					email,
				}, (err2, admin) => {
					if (err2) {
						return done(err2);
					}

					if (!admin) {
						return done(null, false, req.flash('loginMessage', 'Usuário não encontrado.'));
					}

					if (!admin.validPassword(password)) {
						return done(null, false, req.flash('loginMessage', 'Senha incorreta.'));
					}

					return done(null, admin);
				});
			} else {
				if (!user.validPassword(password)) {
					return done(null, false, req.flash('loginMessage', 'Senha incorreta.'));
				}

				return done(null, user);
			}
		});
	}));

	// LOCAL SIGNUP
	passport.use('local-signup', new LocalStrategy({
		usernameField: 'email',
		passwordField: 'password',
		passReqToCallback: true,
	}, (req, email, password, done) => {
		process.nextTick(() => {
			Cliente.findOne({
				email,
			}, (err, existingUser) => {
				if (err) {
					return done(err);
				}

				if (existingUser) {
					return done(null, false, req.flash('signupMessage', 'Email já cadastrado.'));
				}

				if (req.user) {
					const user = req.user;

					user.name = req.body.nome;
					user.address = req.body.endereco;
					user.CPF = req.body.CPF;
					user.phone = req.body.telefone;
					user.email = email;
					user.password = user.generateHash(password);
					user.save((err2) => {
						if (err2) {
							return done(err2);
						}
						return done(null, user, req.flash('appMessage', 'Conta registrada com sucesso.'));
					});
				} else { //  We're not logged in, so we're creating a brand new user.
					// create the user
					const newUser = new Cliente();

					newUser.name = req.body.nome;
					newUser.address = req.body.endereco;
					newUser.CPF = req.body.CPF;
					newUser.phone = req.body.telefone;
					newUser.email = email;
					newUser.password = newUser.generateHash(password);

					newUser.save((err2) => {
						if (err2) {
							return done(err2);
						}

						return done(null, newUser, req.flash('appMessage', 'Conta registrada com sucesso.'));
					});
				}
			});
		});
	}));
};
