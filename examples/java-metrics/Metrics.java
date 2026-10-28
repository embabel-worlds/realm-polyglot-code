package com.acme;

import java.util.List;

public class Metrics {

    private final Object value = (Object) "x";

    int branchy(Object o, List<String> xs) {
        if (o instanceof String s) {
            return s.length();
        } else if (o instanceof Integer) {
            return (Integer) o;
        }
        // if (o == null) { return (int) 0; }
        /* for (String x : xs) { if (x.isEmpty()) return 1; } */
        for (String x : xs) {
            if (x.isEmpty()) {
                continue;
            }
        }
        for (int i = 0; i < 3; i++) {
            while (i > 10) {
                i--;
            }
        }
        do {
            o = null;
        } while (o != null);
        switch (xs.size()) {
            case 0 -> { return 0; }
            default -> { }
        }
        try {
            return ((Number) o).intValue();
        } catch (ClassCastException e) {
            return -1;
        }
    }

    String plain() {
        String s = "if (x) { (int) y; }";
        return s;
    }
}
