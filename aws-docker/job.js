const fs = require('fs')
const path = require('path')

console.info('Test ECR and Batch')

const filePath = path.join('app', 'sftp', 'file.txt')

fs.writeFileSync(filePath, 'Hello World!')

const fileContent = fs.readFileSync(filePath)

console.info('File content: ', fileContent.toString('utf-8'))