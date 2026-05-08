pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import qs.config
import qs.services

Singleton {
  function numericDuration(seconds: int): string {
    if (seconds < 0)
      return "0:00";

    const hours = Math.floor(seconds / 3600);
    seconds %= 3600;

    const minutes = Math.floor(seconds / 60);
    seconds %= 60;

    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    } else {
      return `${minutes}:${seconds.toString().padStart(2, '0')}`;
    }
  }

  function prettyDuration(seconds: int, compact = false): string {
    if (seconds < 0) {
      return "Invalid duration";
    }

    const days = Math.floor(seconds / 86400);
    seconds %= 86400;

    const hours = Math.floor(seconds / 3600);
    seconds %= 3600;

    const minutes = Math.floor(seconds / 60);
    seconds %= 60;

    const parts = [];
    if (compact) {
      if (days > 0)
        parts.push(`${days}d`);

      if (hours > 0)
        parts.push(`${hours}h`);

      if (minutes > 0)
        parts.push(`${minutes}m`);

      if (seconds > 0 || parts.length === 0)
        parts.push(`${seconds}s`);

      return parts.join(" ");
    } else {
      if (days > 0)
        parts.push(`${days} day${days > 1 ? "s" : ""}`);

      if (hours > 0)
        parts.push(`${hours} hour${hours > 1 ? "s" : ""}`);

      if (minutes > 0)
        parts.push(`${minutes} minute${minutes > 1 ? "s" : ""}`);

      if (seconds > 0 || parts.length === 0)
        parts.push(`${seconds} second${seconds !== 1 ? "s" : ""}`);

      if (parts.length > 1) {
        return parts.slice(0, -1).join(", ") + " and " + parts[parts.length - 1];
      } else {
        return parts[0];
      }
    }
  }

  function temperature(temperature: double): string {
    if (Config.locale.temperatureUnit === "fahrenheit") {
      const convertedTemperature = temperature * 1.8 + 32;
      return convertedTemperature.toFixed(1) + " °F";
    } else {
      return temperature.toFixed(1) + " °C";
    }
  }

  function time(showAP = true): string {
    const format = Qt.formatTime(Clock.date, Config.locale.timeFormat);
    if (!showAP) {
      return format.replace(/ (AM|PM|am|pm)/, "");
    }

    return format;
  }

  function dateFull(): string {
    return Qt.formatDate(Clock.date, Config.locale.dateFullFormat);
  }

  function dateShort(): string {
    return Qt.formatDate(Clock.date, Config.locale.dateShortFormat);
  }

  function numberToKanji(n) {
    if (!Number.isInteger(n) || n < 0 || n > 100) {
      throw new Error("Input must be an integer between 0 and 100.");
    }

    const digits = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"];

    if (n === 0)
      return digits[0];
    if (n === 100)
      return "百";

    const tens = Math.floor(n / 10);
    const ones = n % 10;

    let result = "";

    if (tens > 0) {
      if (tens > 1) {
        result += digits[tens];
      }
      result += "十";
    }

    if (ones > 0) {
      result += digits[ones];
    }

    return result;
  }
}
