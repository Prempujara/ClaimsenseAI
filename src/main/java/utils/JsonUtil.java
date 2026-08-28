package utils;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Minimal, dependency-free JSON parser + writer.
 *
 * <p>Only what the app needs to talk to the Python ML service: parses JSON
 * text into {@code Map<String,Object>} / {@code List<Object>} / String /
 * Double / Boolean / null, and writes those back out. Avoids pulling in
 * Gson/Jackson for a couple of tiny flat payloads.</p>
 */
public final class JsonUtil {

    private JsonUtil() { }

    /* ===================== Parsing ===================== */

    public static Object parse(String json) {
        if (json == null) return null;
        Parser p = new Parser(json);
        p.skipWs();
        Object v = p.readValue();
        p.skipWs();
        return v;
    }

    /** Parse a JSON object into a map (empty map if it is not an object). */
    @SuppressWarnings("unchecked")
    public static Map<String, Object> parseObject(String json) {
        Object o = parse(json);
        return (o instanceof Map) ? (Map<String, Object>) o : new LinkedHashMap<>();
    }

    /* ---- typed getters over a parsed map ---- */

    public static String getString(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v == null ? null : String.valueOf(v);
    }

    public static Double getDouble(Map<String, Object> m, String key) {
        Object v = m.get(key);
        if (v instanceof Number) return ((Number) v).doubleValue();
        if (v instanceof String) {
            try { return Double.parseDouble((String) v); } catch (Exception e) { return null; }
        }
        return null;
    }

    public static boolean getBool(Map<String, Object> m, String key, boolean def) {
        Object v = m.get(key);
        if (v instanceof Boolean) return (Boolean) v;
        if (v instanceof String)  return Boolean.parseBoolean((String) v);
        return def;
    }

    private static final class Parser {
        private final String s;
        private int i;
        Parser(String s) { this.s = s; }

        void skipWs() {
            while (i < s.length() && Character.isWhitespace(s.charAt(i))) i++;
        }

        Object readValue() {
            skipWs();
            if (i >= s.length()) return null;
            char c = s.charAt(i);
            switch (c) {
                case '{': return readObject();
                case '[': return readArray();
                case '"': return readString();
                case 't': case 'f': return readBool();
                case 'n': i += 4; return null;               // null
                default:  return readNumber();
            }
        }

        Map<String, Object> readObject() {
            Map<String, Object> m = new LinkedHashMap<>();
            i++; // {
            skipWs();
            if (i < s.length() && s.charAt(i) == '}') { i++; return m; }
            while (i < s.length()) {
                skipWs();
                String key = readString();
                skipWs();
                if (i < s.length() && s.charAt(i) == ':') i++;
                Object val = readValue();
                m.put(key, val);
                skipWs();
                if (i < s.length() && s.charAt(i) == ',') { i++; continue; }
                if (i < s.length() && s.charAt(i) == '}') { i++; break; }
                break;
            }
            return m;
        }

        List<Object> readArray() {
            List<Object> list = new ArrayList<>();
            i++; // [
            skipWs();
            if (i < s.length() && s.charAt(i) == ']') { i++; return list; }
            while (i < s.length()) {
                list.add(readValue());
                skipWs();
                if (i < s.length() && s.charAt(i) == ',') { i++; continue; }
                if (i < s.length() && s.charAt(i) == ']') { i++; break; }
                break;
            }
            return list;
        }

        String readString() {
            StringBuilder sb = new StringBuilder();
            if (i < s.length() && s.charAt(i) == '"') i++; // opening quote
            while (i < s.length()) {
                char c = s.charAt(i++);
                if (c == '"') break;
                if (c == '\\' && i < s.length()) {
                    char e = s.charAt(i++);
                    switch (e) {
                        case 'n': sb.append('\n'); break;
                        case 't': sb.append('\t'); break;
                        case 'r': sb.append('\r'); break;
                        case 'b': sb.append('\b'); break;
                        case 'f': sb.append('\f'); break;
                        case '/': sb.append('/');  break;
                        case '"': sb.append('"');  break;
                        case '\\': sb.append('\\'); break;
                        case 'u':
                            if (i + 4 <= s.length()) {
                                sb.append((char) Integer.parseInt(s.substring(i, i + 4), 16));
                                i += 4;
                            }
                            break;
                        default: sb.append(e);
                    }
                } else {
                    sb.append(c);
                }
            }
            return sb.toString();
        }

        Boolean readBool() {
            if (s.startsWith("true", i))  { i += 4; return Boolean.TRUE; }
            if (s.startsWith("false", i)) { i += 5; return Boolean.FALSE; }
            i++;
            return Boolean.FALSE;
        }

        Object readNumber() {
            int start = i;
            while (i < s.length() && "+-0123456789.eE".indexOf(s.charAt(i)) >= 0) i++;
            String num = s.substring(start, i);
            if (num.isEmpty()) return null;
            try { return Double.parseDouble(num); } catch (Exception e) { return null; }
        }
    }

    /* ===================== Writing ===================== */

    public static String write(Object value) {
        StringBuilder sb = new StringBuilder();
        writeValue(sb, value);
        return sb.toString();
    }

    private static void writeValue(StringBuilder sb, Object v) {
        if (v == null) { sb.append("null"); return; }
        if (v instanceof Map) {
            sb.append('{');
            boolean first = true;
            for (Map.Entry<?, ?> e : ((Map<?, ?>) v).entrySet()) {
                if (!first) sb.append(',');
                first = false;
                writeString(sb, String.valueOf(e.getKey()));
                sb.append(':');
                writeValue(sb, e.getValue());
            }
            sb.append('}');
        } else if (v instanceof List) {
            sb.append('[');
            boolean first = true;
            for (Object o : (List<?>) v) {
                if (!first) sb.append(',');
                first = false;
                writeValue(sb, o);
            }
            sb.append(']');
        } else if (v instanceof Number || v instanceof Boolean) {
            sb.append(v.toString());
        } else {
            writeString(sb, v.toString());
        }
    }

    private static void writeString(StringBuilder sb, String str) {
        sb.append('"');
        for (int k = 0; k < str.length(); k++) {
            char c = str.charAt(k);
            switch (c) {
                case '"':  sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n");  break;
                case '\r': sb.append("\\r");  break;
                case '\t': sb.append("\\t");  break;
                default:
                    if (c < 0x20) sb.append(String.format("\\u%04x", (int) c));
                    else sb.append(c);
            }
        }
        sb.append('"');
    }
}
