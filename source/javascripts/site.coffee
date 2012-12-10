app = angular.module 'infiniteScrollSite', []

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

  $scope.selectedVersion = if latestStable then latestStable else 'master'
  $scope.versionIsStable = versionIsStable
  $scope.versionIsUnstable = versionIsUnstable

  $scope.versionLabel = (version) ->
    info = version
    info += " (latest unstable release)" if version == latestUnstable
    info += " (latest stable release)" if version == latestStable
    info += " (development head)" if version == 'master'
    info
]
