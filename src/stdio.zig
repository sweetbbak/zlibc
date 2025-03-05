const std = @import("std");

/// default buffer size
const BUFSIZE = 8192;

/// The value returned by fgetc and similar functions to indicate the
/// end of the file.
const EOF = -1;

/// Seek from beginning of file.
const SEEK_SET = 0;
/// Seek from current position.
const SEEK_CUR = 1;
/// Seek from end of file.
const SEEK_END = 2;

const L_tmpnam = 20;
const TMP_MAX = 238328;
