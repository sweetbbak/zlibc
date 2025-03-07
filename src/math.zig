const std = @import("std");
const math = std.math;

pub export fn exp(x: f64) callconv(.C) f64 {
    return math.exp(x);
}

pub export fn log(x: f64) callconv(.C) f64 {
    return math.log(f64, 10, x);
}

pub export fn log10(x: f64) callconv(.C) f64 {
    return math.log10(x);
}

pub export fn acos(x: f64) callconv(.C) f64 {
    return math.acos(x);
}

pub export fn asin(x: f64) callconv(.C) f64 {
    return math.asin(x);
}

pub export fn atan(x: f64) callconv(.C) f64 {
    return math.atan(x);
}

pub export fn atan2(y: f64, x: f64) callconv(.C) f64 {
    return math.atan2(y, x);
}

pub export fn tan(x: f64) callconv(.C) f64 {
    return math.tan(x);
}

pub export fn frexp(value: f32, expo: *c_int) callconv(.C) f64 {
    // TODO: look into error handling to match C spec
    const result = math.frexp(value);
    // exp.* = result.exponent;
    expo.* = @as(c_int, @intCast(result.exponent));
    return result.significand;
}

pub export fn ldexp(x: f64, expo: c_int) callconv(.C) f64 {
    // TODO: look into error handling to match C spec
    return math.ldexp(x, @as(i32, @intCast(expo)));
}

pub export fn pow(x: f64, y: f64) callconv(.C) f64 {
    // TODO: look into error handling to match C spec
    return math.pow(f64, x, y);
}
