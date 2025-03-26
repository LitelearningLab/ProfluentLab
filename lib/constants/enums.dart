enum authProblems { UserNotFound, PasswordNotValid, NetworkError }

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  unauthenticated,
  userNotExist,
  userInactive,
  deviceChanged,
  otpVerify,
  event,
  business,
  job,
  signUp,
  group,
  noNetwork,
  walkThrough,
  tutorial,
}

enum PlayerState { stopped, playing, paused }

enum PlayingRouteState { speakers, earpiece }

enum TtsState { playing, stopped, paused, continued }

enum DialogType { Basic, Form }
