$ ->
  addHash = ->
    location.hash = '#download'
  removeHash = ->
    location.hash = ''

  if location.hash == '#download'
    $("#download-modal").reveal
      close: removeHash

  $('[data-show-downloads]').click (evt) ->
    evt.preventDefault()
    $("#download-modal").reveal
      open: addHash
      close: removeHash

app = angular.module 'infiniteScrollSite', ['infinite-scroll']

app.controller 'DownloadsController', ['$scope', ($scope) ->
  versionTuple = (version) ->
    version = version.replace 'v', ''
    tuple = version.split '.'
    (parseInt(n, 10) for n in tuple)

  versionIsStable = (version) ->
    try
      tuple = versionTuple(version)
      tuple[1] % 2 == 0
    catch e
      false

  versionIsUnstable = (version) ->
    try
      tuple = versionTuple(version)
      tuple[1] % 2 == 1
    catch e
      false

  $scope.versions = [
    'master'
    '0.1.0'
    '0.2.0'
    '1.0.0'
  ]

  $scope.versions = _($scope.versions).sort (a, b) ->
    # master always goes at the top
    return -1 if a == 'master'
    return  1 if b == 'master'

    [a, b] = (versionTuple(v) for v in [a, b])

    for i in [0, 1, 2]
      return -1 if a[i] > b[i]
      return  1 if a[i] < b[i]
    return 0

  stableVersions   = _($scope.versions).filter versionIsStable
  unstableVersions = _($scope.versions).filter versionIsUnstable
  latestStable     = stableVersions[0]
  latestUnstable   = unstableVersions[0]

  if latestStable
    $scope.selectedVersion = latestStable
  else if latestUnstable
    $scope.selectedVersion = latestUnstable
  else
    $scope.selectedVersion = 'master'

  $scope.versionIsStable = versionIsStable
  $scope.versionIsUnstable = versionIsUnstable

  $scope.versionLabel = (version) ->
    info = version
    info += " (latest unstable release)" if version == latestUnstable
    info += " (latest stable release)" if version == latestStable
    info += " (development head)" if version == 'master'
    info
]

app.controller 'BasicDemoController', ['$scope', ($scope) ->
  $scope.items = [1..64]
  $scope.enabled = true

  $scope.loadMore = ->
    lastNum = $scope.items[$scope.items.length - 1]
    for num in [1..8]
      $scope.items.push(lastNum + num)
]

app.factory 'Reddit', ['$http', ($http) ->
  class Reddit
    constructor: ->
      @items = []
      @busy = false
      @after = ''

    nextPage: =>
      return if @busy
      @busy = true

      url = "https://api.reddit.com/hot?after=#{@after}&jsonp=JSON_CALLBACK"
      $http.jsonp(url)
        .success (data) =>
          items = data.data.children
          for item in items
            @items.push(item.data)
          @after = "t3_#{@items[@items.length - 1].id}"
          @busy = false
]

app.controller 'RemoteDemoController', ['$scope', 'Reddit', ($scope, Reddit) ->
  reddit = $scope.reddit = new Reddit()

  $scope.nextPage = ->
    return if $scope.paused()
    reddit.nextPage()

  $scope.paused = ->
    reddit.busy || reddit.items.length >= 1000
]
