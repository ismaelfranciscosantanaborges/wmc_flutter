package com.synergy.wmc.wmc_plugin;

public interface ResultInitListener {
    void onSuccess(Object data);
    void onError(String error,String message,Exception e);
}