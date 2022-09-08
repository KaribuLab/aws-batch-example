'use strict';
const { BatchClient, SubmitJobCommand } = require("@aws-sdk/client-batch");

module.exports.submitJob = async (_event) => {
  const client = new BatchClient();
  const input = {
    jobName: 'tf_test_batch_job', //NOTE: Nombre del Job. No es necesario que sea único
    jobDefinition: process.env.JOB_DEFINITION_ARN, //NOTE: ARN de JobDefinition
    jobQueue: process.env.JOB_QUEUE_ARN, //NOTE: ARN de JobQueue
    timeout: {
      attemptDurationSeconds: 900
    } //NOTE: Timeout en segundos del Job. Mínimo 60 segundos
  };
  const command = new SubmitJobCommand(input);
  const response = await client.send(command);
  console.info('Job submit response: ', response)
};
