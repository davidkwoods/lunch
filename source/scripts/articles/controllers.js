'use strict';

/* Controllers */

function ArticleListController($scope, $http) {
  $http.get('articles.json').success(function(data) {
    var list = [];
    var tagList = [];
    
    // Turn the incoming .json file into a useable array.
    for (var key in data) {
      if (data.hasOwnProperty(key)) {
        var item = data[key];
        list.push(item);
        
        // Add unique tags to the tag list
        for (var tag in item.tags) {
          if (tagList.indexOf(item.tags[tag]) === -1) {
            tagList.push(item.tags[tag]);
          }
        }
      }
    }
    $scope.articles = list;
    $scope.tags = tagList;
    $scope.setSearchTag = function(tag) {
      $scope.searchTag = tag;
    };
  });
}

ArticleListController.$inject = ['$scope', '$http'];



function ArticleDetailController($scope, $routeParams, $http) {
  $http.get('articles/' + $routeParams.articleId + '.json').success(function(data) {
    $scope.article = data;
  });
}

ArticleDetailController.$inject = ['$scope', '$routeParams', '$http'];
