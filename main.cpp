#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <algorithm>

enum TokenType {
    INT_LIT,
    OPERATOR,
    KEYWORD
};

struct Token {
    std::string value;
    TokenType type;
    //std::vector<Token> children;
};

const std::vector<std::string> OPERATORS = {"=", "+", "-", "*", "/", "**", "(", ")", ",", ";"};

std::vector<Token> tokenize(const std::string& source);
std::vector<std::string> parse(const std::vector<Token>& tokens);
void shuntingYard(std::vector<Token>& infix);
int getPrecedence(std::string _operator);


int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Error: Incorrect number of arguments" << std::endl;
        std::cerr << "Expected 1 argument: input file" << std::endl;
        return 1;
    }
    std::string inputFilename = argv[1];
    std::ifstream inputFile(inputFilename);
    std::stringstream fileContents;
    fileContents << inputFile.rdbuf();
    std::string source = fileContents.str();
    inputFile.close();

    std::vector<Token> tokens = tokenize(source);
    shuntingYard(tokens);
    /*std::vector<std::string> assembly = parse(tokens);

    std::string programName;
    if (inputFilename.find_last_of(".") != std::string::npos) {
        programName = inputFilename.substr(0, inputFilename.find_last_of("."));
    } else {
        std::cerr << "Missing file extension on input file" << std::endl;
        return 1;
    }

    std::ofstream outputFile;
    outputFile.open(programName + ".asm");
    for (std::string& line : assembly) {
        outputFile << line << '\n';
    }
    outputFile.close();*/

    for (Token token : tokens) {
        std::cout << token.type << "\t'" << token.value << "'\n";
    }
    //system(("nasm -felf64 " + programName + ".asm").c_str());
    //system(("ld " + programName + ".o -o " + programName).c_str());

    return 0;
}

std::vector<Token> tokenize(const std::string& source) {
    std::vector<Token> tokens;
    for (int i = 0; i < source.size(); i++) {
        //char c = source[i];
        std::string buffer;
        if (isalpha(source[i])) {
            while (isalnum(source[i])) {
                buffer += source[i];
                i++;
            }
            i--;
            tokens.push_back(Token{buffer, TokenType::KEYWORD});
            buffer.clear();
        }
        if (isdigit(source[i])) {
            while (isdigit(source[i])) {
                buffer += source[i];
                i++;
            }
            i--;
            tokens.push_back(Token{buffer, TokenType::INT_LIT});
            buffer.clear();
        }
        std::vector<int> matched_operators;
        for (int j = 0; j < OPERATORS.size(); j++) {
            if (source[i] == OPERATORS[j][0]) {
                matched_operators.push_back(j);
            }
        }
        if (matched_operators.size() > 0) {
            buffer = source[i];
            while (matched_operators.size() > 0) {
                i++;
                buffer += source[i];
                for (int j = 0; j < matched_operators.size(); j++) {
                    if (buffer != OPERATORS[matched_operators[j]].substr(0, buffer.size() + 1)) {
                        matched_operators.erase(matched_operators.begin() + j);
                        j--;
                    }
                }
            }
            i--;
            buffer.pop_back();
            tokens.push_back(Token{buffer, TokenType::OPERATOR});
            buffer.clear();
        }
    }
    return tokens;
}

std::vector<std::string> parse(const std::vector<Token>& tokens) {
    std::vector<std::string> assembly;
    assembly.push_back("global _start");
    assembly.push_back("_start:");
    for (int i = 0; i < tokens.size(); i++) {
        if (tokens[i].type == TokenType::KEYWORD) {
            /*
            mov rax, 60 ; 60 is the syscall number for 'exit'
            mov rdi, 43 ; this is arg0 or in this case, the exit code
            syscall
            */
            assembly.push_back("\tmov rax, 60");
            assembly.push_back("\tmov rdi, " + tokens[i + 1].value);
            assembly.push_back("\tsyscall");
        }
    }
    return assembly;
}

void shuntingYard(std::vector<Token>& infix) {
    std::vector<Token> output;
    std::vector<Token> stack;
    
    for (Token token : infix) {
        // Push any integer literals and variables to the output
        if (token.type == TokenType::INT_LIT) {
            output.push_back(token);
        }
        else if (token.type == TokenType::OPERATOR || token.type == TokenType::KEYWORD) {
            // When encountering ")", pop everything off the stack until you find a matching "(" or ","
            if (token.value == ")") {
                while (stack.back().value != "(" && !stack.empty()) {
                    if (stack.back().value != ",") {
                        output.push_back(stack.back());
                    }
                    stack.pop_back();
                }
                stack.pop_back();
                /*if (!stack.empty()) {
                    if (stack.back().tokenType == TokenType::KEYWORD) {
                        output.push_back(stack.back());
                        stack.pop_back();
                    }
                }*/
            }
            // If the token is a comma, pop everything off the stack until the beginning of the statement or a previous argument is found
            else if (token.value == ",") {
                while (!(stack.back().value == "(" || stack.back().value == ",") && !stack.empty()) {
                    output.push_back(stack.back());
                    stack.pop_back();
                }
                stack.push_back(token);
            }
            // If the token is a semicolon, pop everything off
            else if (token.value == ";") {
                while (stack.size() > 0) {
                    output.push_back(stack.back());
                    stack.pop_back();
                }
            }
            else {
                // if what's currently on the stack has >= precedence to the current token, remove it
                // aka if there's more important things to do, pop them off so they're done first.
                if (token.value != "(") {
                    while (!stack.empty() && getPrecedence(stack.back().value) >= getPrecedence(token.value) && stack.back().value != "(" && stack.back().value != ",") {
                        output.push_back(stack.back());
                        stack.pop_back();
                    }
                }
                stack.push_back(token);
            }
        }
    }
    while (stack.size() > 0) {
        output.push_back(stack.back());
        stack.pop_back();
    }
    infix = output;
}

int getPrecedence(std::string _operator) {
    return std::distance(OPERATORS.begin(), std::find(OPERATORS.begin(), OPERATORS.end(), _operator));
}