module.exports = function authLocal(app, passport, modules) {
	app.get('/logout', modules.isLoggedIn, (req, res) => {
		req.logout();

		res.redirect('/');
	});

	app.get('/login', modules.isLoggedOut, (req, res) => {
		res.render('login.ejs', { message: req.flash('loginMessage') });
	});

	app.post('/login', modules.isLoggedOut, passport.authenticate('local-login', {
		successRedirect: '/login/callback',
		failureRedirect: '/login',
		failureFlash: true,
	}));

	app.get('/login/callback', (req, res) => {
		if (req.user._type === 'Administrador') {
			res.redirect('/admin');
		} else {
			res.redirect('/app');
		}
	});

	app.get('/auth', (req, res) => {
		res.redirect('/login');
	});

	app.get('/signup', modules.isLoggedOut, (req, res) => {
		res.render('signup.ejs', { message: req.flash('signupMessage') });
	});

	app.post('/signup', modules.isLoggedOut, passport.authenticate('local-signup', {
		successRedirect: '/app',
		successFlash: true,
		failureRedirect: '/signup',
		failureFlash: true,
	}));
};
