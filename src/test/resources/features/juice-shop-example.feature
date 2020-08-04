Feature: Juice shop example. FINAL EXAM. GL & HF.

  Background:
    Given the user creates an account using the following data:
      | email                          | RANDOM_EMAIL                     |
      | password                       | easyPassword                       |
      | passwordRepeat                 | easyPassword                       |
      | securityQuestion --> id        | 6                                  |
      | securityQuestion --> question  | Paternal grandmother's first name? |
      | securityQuestion --> createdAt | "2020-07-20T17:08:08.423Z"         |
      | securityQuestion --> updatedAt | "2020-07-20T17:08:08.423Z"         |
      | securityAnswer                 | The Answer that secures            |
    Then user gets status code "201"

  @run
  Scenario: User  creates an account
    Then the value of path "status" is "success"
    And  the path "data" contains the following values:
      | isActive | true         |
      | email    | RANDOM_EMAIL |

  @run
  Scenario: User changes password
    When the user logs in using the following data:
      | email    | RANDOM_EMAIL |
      | password | easyPassword |
    Then user gets status code "200"
    # Add the necessary JSON keys and values to the table.
    When the user changes password using the following data:
      | current | easyPassword |
      | new     | newPassword  |
      | repeat  | newPassword  |
    Then user gets status code "200"

  @run
  Scenario: User logs in
    When the user logs in using the following data:
      | email    | RANDOM_EMAIL |
      | password | easyPassword |
    Then user gets status code "200"
    # Look up JSON path in response.
    And  the value of path "authentication --> umail" is "RANDOM_EMAIL"

  @run
  Scenario: User logs in - Negative
    When the user logs in using the following data:
      | email    | RANDOM_EMAIL        |
      | password | easyPasswordFakeOne |
    # Find the correct status code.
    Then user gets status code "401"

  @run
  Scenario: Data Erasure Request (Art. 17 GDPR)
    When the user logs in using the following data:
      | email    | RANDOM_EMAIL |
      | password | easyPassword |
    Then user gets status code "200"
    # Define the step, find the missing endpoint and response status code.
    When the user requests erasure of personal data using following data:
      | email          | RANDOM_EMAIL            |
      | securityAnswer | The Answer that secures |
    Then user gets status code "202"

  @run
  Scenario: Add item to basket
    When the user logs in using the following data:
      | email    | RANDOM_EMAIL |
      | password | easyPassword |
    Then user gets status code "200"
    # Find the missing endpoint
    When the user adds an item to basket using the following data:
      | ProductId | 27 |
      | quantity  | 1  |
    Then user gets status code "200"
    And  the value of path "status" is "success"
    And  the path "data" contains the following values:
      | ProductId | 27 |
      | quantity  | 1  |

  @run
  Scenario: Add item to basket - negative
    When the user logs in using the following data:
      | email    | RANDOM_EMAIL |
      | password | easyPassword |
    Then user gets status code "200"
    When the user adds an item to basket using the following data:
      | ProductId | 27 |
      | quantity  | 2  |
    # Find the correct status code.
    Then user gets status code "400"
    # Fix the message of the error code
    And the value of path "error" is "We are out of stock! Sorry for the inconvenience."

  @run
  Scenario: Add multiple items to basket
    When the user logs in using the following data:
      | email    | RANDOM_EMAIL |
      | password | easyPassword |
    Then user gets status code "200"
    # Find the missing endpoint.
    When the user adds an item to basket using the following data:
      | ProductId | 27 |
      | quantity  | 1 |
    Then user gets status code "200"
    And  the user adds an item to basket using the following data:
      | ProductId | 22 |
      | quantity  | 2  |
    Then user gets status code "200"
    # Find the missing endpoint
    When the user requests the basket content
    Then user gets status code "200"
    And  the array path "data --> Products" at index "0" contains following data:
      | id                      | 22             |
      | name                    | Green Smoothie |
      | BasketItem --> quantity | 2              |
    And  the array path "data --> Products" at index "1" contains following data:
      | id                      | 27                 |
      | name                    | Juice Shop Artwork |
      | BasketItem --> quantity | 1                  |

  @run
  Scenario: Add address
    When the user logs in using the following data:
      | email    | RANDOM_EMAIL |
      | password | easyPassword |
    Then user gets status code "200"
    # Define method, add the necessary JSON keys and values
    When the user adds an address with the following data:
      | country       | Latvia                    |
      | fullName      | Some name                 |
      | mobileNum     | 12345678                  |
      | zipCode       | LV-1111                   |
      | streetAddress | This is my street address |
      | city          | Ventspils                 |
      | state         | TestState                 |
    # Find the correct status code
    Then user gets status code "201"
    And  the value of path "status" is "success"
    And  the user received one value in path "data --> id" and sets session variable with this name "address_id"
    # Validate previously created address
    And  the path "data" contains the following values:
      | country       | Latvia                    |
      | fullName      | Some name                 |
      | mobileNum     | 12345678                  |
      | zipCode       | LV-1111                   |
      | streetAddress | This is my street address |
      | city          | Ventspils                 |
      | state         | TestState                 |

  @run
  Scenario: Validate delivery options
    When the user logs in using the following data:
      | email    | RANDOM_EMAIL |
      | password | easyPassword |
    Then user gets status code "200"
    # Define the method and find the missing endpoint
    When the user requests delivery options
    Then user gets status code "200"
    And  the value of path "status" is "success"
    And  the array path "data" at index "0" contains following data:
      | id    | 1                 |
      | name  | One Day Delivery  |
      | price | 0.99              |
      | eta   | 1                 |
    And  the array path "data" at index "1" contains following data:
      | id    | 2                 |
      | name  | Fast Delivery     |
      | price | 0.5               |
      | eta   | 3                 |
    And  the array path "data" at index "2" contains following data:
      | id    | 3                 |
      | name  | Standard Delivery |
      | price | 0                 |
      | eta   | 5                 |

  @run
  Scenario: Add a credit card
    When the user logs in using the following data:
      | email    | RANDOM_EMAIL |
      | password | easyPassword |
    Then user gets status code "200"
    # Defined the method, add the necessary JSON keys and values, find the endpoint.
    When the user adds a credit card with following data:
      | fullName | Test Name        |
      | cardNum  | 1111111111111111 |
      | expMonth | 3                |
      | expYear  | 2084             |
    # Find the correct status code.
    Then user gets status code "201"
    And  the user received one value in path "data --> id" and sets session variable with this name "card_id"
    And  the path "data" contains the following values:
      | fullName | Test Name        |
      | cardNum  | 1111111111111111 |
      | expMonth | 3                |
      | expYear  | 2084             |

  @run
  Scenario: Buy an item
    When the user logs in using the following data:
      | email    | RANDOM_EMAIL |
      | password | easyPassword |
    Then user gets status code "200"
    When the user adds an item to basket using the following data:
      | ProductId | 27 |
      | quantity  | 1  |
    Then user gets status code "200"
    # Add the necessary JSON keys and values.
    When the user adds an address with the following data:
      | country       | Latvia                    |
      | fullName      | Some name                 |
      | mobileNum     | 12345678                  |
      | zipCode       | LV-1111                   |
      | streetAddress | This is my street address |
      | city          | Ventspils                 |
      | state         | TestState                 |
    # Find the correct status code.
    Then user gets status code "201"
    When the user requests delivery options
    Then user gets status code "200"
    When the user adds a credit card with following data:
      | fullName | Test Name        |
      | cardNum  | 1111111111111111 |
      | expMonth | 3                |
      | expYear  | 2084             |
    # Find the correct status code.
    Then user gets status code "201"
    # Fix the 'purchaseTheItems' method
    When the user purchases the items using the following data:
      | couponData                        | bnVsbA== |
      | orderDetails --> deliveryMethodId | 1        |
    Then user gets status code "200"

  @run
  Scenario: User forgot password
    When the user received one value in path "data --> id" and sets session variable with this name "user_id"
    # Define th step, find the correct json values, use user_id
    And  the user sends security answer
      | answer             | The Answer that secures |
      | SecurityQuestionId | 6                       |
    # Find the correct status code.
    Then user gets status code "201"
    # Define the missing endpoint
    When the user requests to reset password using the following data:
      | email  | RANDOM_EMAIL            |
      | answer | The Answer that secures |
      | new    | newEasyPassword         |
      | repeat | newEasyPassword         |
    # Find the correct status code.
    Then user gets status code "200"
