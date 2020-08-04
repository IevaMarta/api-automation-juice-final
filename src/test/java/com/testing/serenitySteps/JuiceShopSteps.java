package com.testing.serenitySteps;

import com.testing.requestBodies.BaseRequestBody;
import cucumber.api.DataTable;
import io.restassured.response.Response;
import net.thucydides.core.annotations.Step;

import javax.xml.crypto.Data;
import java.io.IOException;
import java.util.*;

import static net.serenitybdd.core.Serenity.sessionVariableCalled;
import static net.serenitybdd.core.Serenity.setSessionVariable;

@SuppressWarnings("unchecked")
public class JuiceShopSteps extends BaseSteps {
  private final static String _API_USERS_ = "/api/Users/";
  private final static String _REST_USER_LOGIN_ = "/rest/user/login/";
  private final static String _REST_USER_ERASURE_ = "/rest/user/erasure-request/";
  private final static String _API_BASKET_ITEMS_ = "/api/BasketItems/";
  private final static String _REST_BASKET_ = "/rest/basket/";
  private final static String _API_ADDRESS_ = "/api/Addresss/";
  private final static String _API_DELIVERIES_ = "/api/Deliverys/";
  private final static String _API_CARDS_ = "/api/Cards/";
  private final static String _API_SECURITY_ANSWERS_ = "/api/SecurityAnswers/";
  private final static String _REST_USER_RESET_PASSWORD = "/rest/user/reset-password/";

  @Step
  public static void getBasketContent(){
    sendRequest(GET, _REST_BASKET_ + sessionVariableCalled("basket_id"));
  }

  @Step
  public static void addItemToBasket(DataTable dataTable) throws IOException {
    BaseRequestBody requestBody = createBodyCustom(dataTable);
    requestBody.addKey("BasketId", sessionVariableCalled("basket_id").toString());
    sendRequestWithBodyJson(POST, _API_BASKET_ITEMS_, requestBody.getBody());
  }

  @Step
  public static void createAnAccount(DataTable dataTable) throws IOException {
    Map<String, Object> map = new HashMap<>(dataTable.asMap(String.class, String.class));

    if(map.get("email").toString().equals(RANDOM_EMAIL)){
      String randomEmail = "test+" + new Random().nextInt(999999) + "@testdevlab.com";
      map.replace("email", randomEmail);
      setSessionVariable(RANDOM_EMAIL).to(randomEmail);
    }

    sendRequestWithBodyJson(POST, _API_USERS_, createBody(map));
    if (((Response) sessionVariableCalled(RESPONSE)).statusCode() == 201) {
      saveValueInPathToSessionVariable("data --> id", "user_id");
    }
  }

  @Step
  public static void logInAnAccount(DataTable dataTable) throws IOException {
    sendRequestWithBodyJson(POST, _REST_USER_LOGIN_, createBody(handleRandomEmail(dataTable)));
    if (((Response) sessionVariableCalled(RESPONSE)).statusCode() == 200){
      saveValueInPathToSessionVariable("authentication --> token", "token");
      saveValueInPathToSessionVariable("authentication --> bid", "basket_id");
    }
  }

  @Step
  public static void changePassword(DataTable dataTable) throws IOException {
    Map<String, String> requestData = dataTable.asMap(String.class, String.class);
    sendRequestWithBodyJson(GET, createChangePasswordEndpoint(
            requestData.get("current"),
            requestData.get("new"),
            requestData.get("repeat")), "{}");
  }

  @Step
  public static void resetPassword(DataTable dataTable) throws IOException {
    sendRequestWithBodyJson(POST, _REST_USER_RESET_PASSWORD, createBody(handleRandomEmail(dataTable)));
  }

  @Step
  public static void purchaseTheItems(DataTable dataTable) throws IOException {
    BaseRequestBody requestBody = createBodyCustom(dataTable);
    // Add payment id
    requestBody.addKey("orderDetails --> paymentId", sessionVariableCalled("payment_id").toString());
    // Add address id
    requestBody.addKey("orderDetails --> addressId", sessionVariableCalled("address_id").toString());

    sendRequestWithBodyJson(
            POST,
            // Add basket id
            createBasketCheckoutEndpoint(sessionVariableCalled("basket_id").toString()),
            requestBody.getBody());
  }

  @Step
  public static void requestErasure(DataTable dataTable) throws IOException {
    sendRequestWithBodyJson(POST, _REST_USER_ERASURE_, createBody(dataTable));
  }

  @Step
  public static void addAddress(DataTable dataTable) throws IOException {
    sendRequestWithBodyJson(POST, _API_ADDRESS_, createBody(dataTable));
  }

  @Step
  public static void getDeliveryOptions() throws IOException {
    sendRequestWithBodyJson(GET, _API_DELIVERIES_, "{}");
  }

  @Step
  public static void addCreditCard(DataTable dataTable) throws IOException {
    sendRequestWithBodyJson(POST, _API_CARDS_, createBody(dataTable));
  }

  @Step
  public static void sendSecurityAnswer(DataTable dataTable) throws IOException {
    sendRequestWithBodyJson(POST, _API_SECURITY_ANSWERS_ + sessionVariableCalled("user_id"), createBody(dataTable));
  }

  // Private

  private static String createChangePasswordEndpoint(String current, String new_, String repeat){
    return "/rest/user/change-password?current=" + current + "&new=" + new_ + "&repeat=" + repeat;
  }

  private static String createBasketCheckoutEndpoint(String basketId){
    return "/rest/basket/" + basketId + "/checkout";
  }

  private static Map<String, Object> handleRandomEmail(DataTable dataTable){
    Map<String, Object> map = new HashMap<>(dataTable.asMap(String.class, String.class));
    if(map.get("email").toString().equals(RANDOM_EMAIL)){
      map.replace("email", sessionVariableCalled(RANDOM_EMAIL));
    }
    return map;
  }
}
