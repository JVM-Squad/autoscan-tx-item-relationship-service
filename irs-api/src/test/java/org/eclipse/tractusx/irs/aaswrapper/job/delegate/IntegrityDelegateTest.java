/********************************************************************************
 * Copyright (c) 2021,2022,2023
 *       2022: ZF Friedrichshafen AG
 *       2022: ISTOS GmbH
 *       2022,2023: Bayerische Motoren Werke Aktiengesellschaft (BMW AG)
 *       2022,2023: BOSCH AG
 * Copyright (c) 2021,2022,2023 Contributors to the Eclipse Foundation
 *
 * See the NOTICE file(s) distributed with this work for additional
 * information regarding copyright ownership.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Apache License, Version 2.0 which is available at
 * https://www.apache.org/licenses/LICENSE-2.0. *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 ********************************************************************************/
package org.eclipse.tractusx.irs.aaswrapper.job.delegate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.eclipse.tractusx.irs.aaswrapper.job.delegate.IntegrityDelegate.DATA_INTEGRITY_ASPECT;
import static org.eclipse.tractusx.irs.util.TestMother.jobParameter;
import static org.eclipse.tractusx.irs.util.TestMother.shellDescriptor;
import static org.eclipse.tractusx.irs.util.TestMother.submodelDescriptorWithDspEndpoint;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.Objects;

import org.eclipse.tractusx.irs.aaswrapper.job.AASTransferProcess;
import org.eclipse.tractusx.irs.aaswrapper.job.ItemContainer;
import org.eclipse.tractusx.irs.component.Bpn;
import org.eclipse.tractusx.irs.component.JobParameter;
import org.eclipse.tractusx.irs.component.PartChainIdentificationKey;
import org.eclipse.tractusx.irs.component.enums.ProcessStep;
import org.eclipse.tractusx.irs.edc.client.EdcSubmodelFacade;
import org.eclipse.tractusx.irs.edc.client.exceptions.EdcClientException;
import org.eclipse.tractusx.irs.registryclient.discovery.ConnectorEndpointsService;
import org.eclipse.tractusx.irs.util.JsonUtil;
import org.junit.jupiter.api.Test;

class IntegrityDelegateTest {

    final EdcSubmodelFacade submodelFacade = mock(EdcSubmodelFacade.class);
    final ConnectorEndpointsService connectorEndpointsService = mock(ConnectorEndpointsService.class);
    final JsonUtil jsonUtil = new JsonUtil();
    final IntegrityDelegate integrityDelegate = new IntegrityDelegate(null, submodelFacade,
            connectorEndpointsService, jsonUtil);

    private static PartChainIdentificationKey createKey() {
        return PartChainIdentificationKey.builder().globalAssetId("itemId").bpn("bpn123").build();
    }

    @Test
    void shouldFillItemContainerWithDataIntegrityAspect()
            throws EdcClientException, URISyntaxException, IOException {
        // given
        when(submodelFacade.getSubmodelRawPayload(anyString(), anyString(), anyString())).thenReturn(Files.readString(
                Paths.get(Objects.requireNonNull(IntegrityDelegateTest.class.getResource("/dataIntegrity.json")).toURI())));
        when(connectorEndpointsService.fetchConnectorEndpoints(any())).thenReturn(List.of("http://localhost"));

        final ItemContainer.ItemContainerBuilder itemContainerWithShell = ItemContainer.builder()
                                                                                       .shell(shellDescriptor(
                                                                                               List.of(submodelDescriptorWithDspEndpoint(
                                                                                                       DATA_INTEGRITY_ASPECT,
                                                                                                       "address"))));

        // when
        final ItemContainer result = integrityDelegate.process(itemContainerWithShell, jobParameter(),
                new AASTransferProcess(), createKey());

        // then
        assertThat(result).isNotNull();
        assertThat(result.getIntegrities()).isNotEmpty();
        assertThat(result.getIntegrities().stream().findAny().get().getChildParts()).isNotEmpty();
    }

    @Test
    void shouldCatchRestClientExceptionAndPutTombstone() throws EdcClientException {
        // given
        when(submodelFacade.getSubmodelRawPayload(anyString(), anyString(), anyString())).thenThrow(
                new EdcClientException("Unable to call endpoint"));
        when(connectorEndpointsService.fetchConnectorEndpoints(any())).thenReturn(List.of("http://localhost"));

        final ItemContainer.ItemContainerBuilder itemContainerWithShell = ItemContainer.builder()
                                                                                       .shell(shellDescriptor(
                                                                                               List.of(submodelDescriptorWithDspEndpoint(
                                                                                                       DATA_INTEGRITY_ASPECT,
                                                                                                       "address"))));

        // when
        final ItemContainer result = integrityDelegate.process(itemContainerWithShell, jobParameter(),
                new AASTransferProcess(), createKey());

        // then
        assertThat(result).isNotNull();
        assertThat(result.getTombstones()).hasSize(1);
        assertThat(result.getTombstones().get(0).getCatenaXId()).isEqualTo("itemId");
        assertThat(result.getTombstones().get(0).getProcessingError().getProcessStep()).isEqualTo(
                ProcessStep.DATA_INTEGRITY_CHECK);
    }

    @Test
    void shouldPutTombstoneForMissingBpn() {
        final ItemContainer.ItemContainerBuilder itemContainerWithShell = ItemContainer.builder()
                                                                                       .shell(shellDescriptor(
                                                                                               List.of(submodelDescriptorWithDspEndpoint(
                                                                                                       DATA_INTEGRITY_ASPECT,
                                                                                                       "address"))));
        // when
        final ItemContainer result = integrityDelegate.process(itemContainerWithShell, jobParameter(),
                new AASTransferProcess(), PartChainIdentificationKey.builder().globalAssetId("testId").build());

        // then
        assertThat(result).isNotNull();
        assertThat(result.getTombstones()).hasSize(1);
        assertThat(result.getTombstones().get(0).getCatenaXId()).isEqualTo("testId");
        assertThat(result.getTombstones().get(0).getProcessingError().getProcessStep()).isEqualTo(
                ProcessStep.DATA_INTEGRITY_CHECK);
    }

    @Test
    void shouldNotValidateIntegrityChainWhenFlagIsDisabled() {
        // given
        final JobParameter notValidateIntegrityParam = JobParameter.builder().integrityCheck(false).build();
        final ItemContainer.ItemContainerBuilder itemContainer = ItemContainer.builder().bpn(Bpn.withManufacturerId("BPNL00000003AYRE"));

        // when
        final ItemContainer result = integrityDelegate.process(itemContainer, notValidateIntegrityParam,
                new AASTransferProcess("id", 0), createKey());

        // then
        assertThat(result).isNotNull();
        assertThat(result.getIntegrities()).isEmpty();
    }
}