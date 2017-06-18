/* global angular, ngapp */

ngapp.config(function appConfig($routeProvider, $locationProvider) {
	$locationProvider.html5Mode(true);

	$routeProvider.when('/app', {
		redirectTo: '/admin',
	});
	$routeProvider.when('/admin', {
		controller: 'adminController',
		templateUrl: '/template/admin.html',
	});
	$routeProvider.when('/admin/criar', {
		controller: 'adminController',
		templateUrl: '/template/adminCriar.html',
	});
	$routeProvider.when('/admin/validar', {
		controller: 'adminController',
		templateUrl: '/template/adminValidar.html',
	});
	$routeProvider.when('/admin/editar', {
		controller: 'listarLeilaoController',
		templateUrl: '/template/adminEditar.html',
	});
	$routeProvider.when('/admin/finalizar', {
		controller: 'adminController',
		templateUrl: '/template/adminFinalizar.html',
	});
	$routeProvider.when('/admin/relatorios', {
		controller: 'adminController',
		templateUrl: '/template/adminRelatorios.html',
	});
	$routeProvider.when('/admin/relatorios/:state', {
		controller: 'adminController',
		templateUrl: '/template/adminRelatorios.html',
	});
});
