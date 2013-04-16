'use strict';

/* Controllers */

function ArticleListController($scope, $http) {
  $http.get('articles.json').success(function(data) {
    var list = [];
    for (var key in data) {
      if (data.hasOwnProperty(key)) {
        list.push(data[key]);
      }
    }
    $scope.articles = list;
  });
}

ArticleListController.$inject = ['$scope', '$http'];



function ArticleDetailController($scope, $routeParams, $http) {
  $http.get('articles/' + $routeParams.articleId + '.md').success(function(data) {
    $scope.article = data;
  });
}

ArticleDetailController.$inject = ['$scope', '$routeParams', '$http'];
