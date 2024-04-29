/********************************************************************************
 * Copyright (c) 2022,2024 Bayerische Motoren Werke Aktiengesellschaft (BMW AG)
 * Copyright (c) 2021,2024 Contributors to the Eclipse Foundation
 *
 * See the NOTICE file(s) distributed with this work for additional
 * information regarding copyright ownership.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Apache License, Version 2.0 which is available at
 * https://www.apache.org/licenses/LICENSE-2.0.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 ********************************************************************************/
package org.eclipse.tractusx.irs.cucumber;

import static io.restassured.RestAssured.given;

import java.io.File;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import io.restassured.specification.RequestSpecification;

/**
 * Helper class for E2E tests.
 */
public class E2ETestHelper {

    public static final ObjectMapper objectMapper;

    static {
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        objectMapper.configure(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false);
    }

    public static File getExpectedFile(final String fileName) {
        final String path = "expected-files/" + fileName;
        return getFile(path);
    }

    public static File getFile(final String path) {
        final ClassLoader classLoader = E2ETestHelper.class.getClassLoader();
        return new File(classLoader.getResource(path).getFile());
    }

    public static RequestSpecification givenAuthentication(
            AuthenticationProperties.AuthenticationPropertiesBuilder authBuilder) {
        final AuthenticationProperties authProperties = authBuilder.build();
        return given().log().all().spec(authProperties.getNewAuthenticationRequestSpecification());
    }

}
