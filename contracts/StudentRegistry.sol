// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract StudentRegs {
    struct Student {
        address studentAddr;
        string name;
        uint256 studentId;
        uint8 age;
    }

    address public owner;

    constructor() {
        owner = msg.sender;  // address of the contract deployer
    }

    // dynamic array of students
    Student[] private students;
    mapping(address => Student) public studentMapping;

    modifier onlyOwner() {
        require(owner == msg.sender, "You're not authorized");
        _;
    }

    modifier isNotAddressZero() {
        require(msg.sender != address(0), "Invalid address");
        _;
    }

    event StudentAdded(address indexed studentAddr, uint256 studentId);
    event StudentUpdated(address indexed studentAddr, uint256 studentId);
    event StudentDeleted(address indexed studentAddr, uint256 studentId);

    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner isNotAddressZero {
        require(_studentAddr != address(0), "Invalid address");
        require(bytes(_name).length > 0, "Name cannot be blank");
        require(_age >= 18, "Student age must be at least 18");

        uint256 _studentId = students.length + 1;
        Student memory student = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentId
        });

        students.push(student);
        studentMapping[_studentAddr] = student;

        emit StudentAdded(_studentAddr, _studentId);
    }

    function getStudent(uint256 _studentId) public view returns (Student memory) {
        require(_studentId > 0 && _studentId <= students.length, "Invalid student ID");
        return students[_studentId - 1];
    }

    function getStudentFromMapping(address _studentAddr) public view returns (Student memory) {
        require(studentMapping[_studentAddr].studentId != 0, "Student not found");
        return studentMapping[_studentAddr];
    }

    function deleteStudentFromMapping(address _studentAddr) public onlyOwner {
        require(studentMapping[_studentAddr].studentId != 0, "Student not found");
        uint256 studentId = studentMapping[_studentAddr].studentId;
        delete studentMapping[_studentAddr];

        emit StudentDeleted(_studentAddr, studentId);
    }

    function updateStudent(
        uint256 _studentId,
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner {
        require(_studentId > 0 && _studentId <= students.length, "Invalid student ID");
        require(_age >= 18, "Student age must be at least 18");

        uint256 index = _studentId - 1;

        Student storage student = students[index];
        student.studentAddr = _studentAddr;
        student.name = _name;
        student.age = _age;

        studentMapping[_studentAddr] = student;

        emit StudentUpdated(_studentAddr, _studentId);
    }

    function deleteStudent(uint256 _studentId) public onlyOwner {
        require(_studentId > 0 && _studentId <= students.length, "Invalid student ID");

        uint256 studentId = students[_studentId - 1].studentId;
        address studentAddr = students[_studentId - 1].studentAddr;

        // Move the last element into the place to delete
        students[_studentId - 1] = students[students.length - 1];
        // Remove the last element
        students.pop();

        delete studentMapping[studentAddr];
        emit StudentDeleted(studentAddr, studentId);
    }
}

