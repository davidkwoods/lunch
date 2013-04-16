'use strict';

/* App Module */

angular.module('articleApp', []).
  config(['$routeProvider', function($routeProvider) {
  $routeProvider.
      when('/articles', {templateUrl: 'partials/articleList.html',   controller: ArticleListController}).
      when('/articles/:articleId', {templateUrl: 'partials/articleDetail.html', controller: ArticleDetailController}).
      otherwise({redirectTo: '/articles'});
}]);
