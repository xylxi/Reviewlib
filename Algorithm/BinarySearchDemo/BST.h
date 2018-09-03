//
// Created by DMW_W on 2018/8/26.
//

#ifndef BINARYSEARCHDEMO_BST_H
#define BINARYSEARCHDEMO_BST_H

#include <iostream>
using namespace std;

// 二分搜索树
template <typename Key, typename Value>
class BST {

private:
    struct Node{
        Key key;
        Value value;
        Node *left;
        Node *right;

        Node(Key key, Value value){
            this->key = key;
            this->value = value;
            this->left = this->right = NULL;
        }

        Node(Node *node){
            this->key = node->key;
            this->value = node->value;
            this->left = node->left;
            this->right = node->right;
        }

    };

    Node *root; // 根节点
    int count;  // 节点个数

public:
    BST() {
        root = NULL;
        count = 0;
    }

    ~BST() {
        destroy(root);
    }

    int size() {
        return count;
    }

    bool isEmpty() {
        return count == 0;
    }

    // 向二分搜索树中插入一个新的(key, value)数据对
    void insert(Key key, Value value){
        root = insert(root, key, value);
    }

    // 查看二分搜索树中是否存在键key
    bool contain(Key key){
        return contain(root, key);
    }

    // 在二分搜索树中搜索键key所对应的值。如果这个值不存在, 则返回NULL
    Value* search(Key key){
        return search( root , key );
    }

    // 二分搜索树的前序遍历
    void preOrder(){
        preOrder(root);
    }

    // 二分搜索树的中序遍历
    void inOrder(){
        inOrder(root);
    }

    // 二分搜索树的后序遍历
    void postOrder(){
        postOrder(root);
    }

    // 寻找二分搜索树的最小的键值
    Key minimum(){
        assert( count != 0 );
        Node* minNode = minimum( root );
        return minNode->key;
    }

    // 寻找二分搜索树的最大的键值
    Key maximum(){
        assert( count != 0 );
        Node* maxNode = maximum(root);
        return maxNode->key;
    }

    // 从二分搜索树中删除最小值所在节点
    void removeMin(){
        if( root )
            root = removeMin( root );
    }

    // 从二分搜索树中删除最大值所在节点
    void removeMax(){
        if( root )
            root = removeMax( root );
    }

    // 从二分搜索树中删除键值为key的节点
    void remove(Key key){
        root = remove(root, key);
    }


private:
    // 向以node为根的二分搜索树中, 插入节点(key, value), 使用递归算法
    // 返回插入新节点后的二分搜索树的根
    Node* insert(Node *root, Key key, Value value) {
        if (root == NULL) {
            count++;
            return new Node(key,value);
        }

        if (root->key > key) {
            root->left = insert(root->left,key,value);
        } else if (root->key < key) {
            root->right = insert(root->right,key,value);
        } else {
            root->value = value;
        }
        return root;
    }

    // 查看以node为根的二分搜索树中是否包含键值为key的节点, 使用递归算法
    bool contain(Node *root, Key key) {
        if (root == NULL)
            return false;
        if (root->key == key) {
            return true;
        } else if (root->key > key) {
            return contain(root->left, key);
        } else {
            return contain(root->right, key);
        }
    }

    // 在以node为根的二分搜索树中查找key所对应的value, 递归算法
    // 若value不存在, 则返回NULL
    Value* search(Node *root, Key key) {
        if (root == NULL)
            return NULL;
        if (root->key == key)
            return &root->value;
        else if (root->key > key)
            return search(root->left, key);
        else
            return search(root->right, key);
    }

    void preOrder(Node *root) {
        if (root == NULL)
            return;
        cout<<root->key<<endl;
        preOrder(root->left);
        preOrder(root->right);
    }

    void inOrder(Node *root) {
        if (root == NULL)
            return;
        inOrder(root->left);
        cout<<root->key<<endl;
        inOrder(root->right);
    }

    void postOrder(Node *root) {
        if (root == NULL)
            return;
        postOrder(root->left);
        postOrder(root->right);
        cout<<root->key<<endl;
    }

    // 释放以node为根的二分搜索树的所有节点
    // 采用后续遍历的递归算法
    void destroy(Node* node){
        if( node != NULL ){
            destroy( node->left );
            destroy( node->right );
            delete node;
            count --;
        }
    }

    Node* minimum(Node *root) {
        if (root->left == NULL)
            return root;
        return minimum(root->left);
    }


    Node* maximum(Node *root) {
        if (root->right == NULL)
            return root;
        return minimum(root->right);
    }

    // 删除掉以node为根的二分搜索树中的最小节点
    // 返回删除节点后新的二分搜索树的根
    Node* removeMin(Node* node){
        if( node->left == NULL ){

            Node* rightNode = node->right;
            delete node;
            count --;
            return rightNode;
        }

        node->left = removeMin(node->left);
        return node;
    }

    // 删除掉以node为根的二分搜索树中的最大节点
    // 返回删除节点后新的二分搜索树的根
    Node* removeMax(Node* node){

        if( node->right == NULL ){

            Node* leftNode = node->left;
            delete node;
            count --;
            return leftNode;
        }

        node->right = removeMax(node->right);
        return node;
    }

    // 删除掉以node为根的二分搜索树中键值为key的节点, 递归算法
    // 返回删除节点后新的二分搜索树的根
    Node* remove(Node *node, Key key) {
        if (node == NULL)
            return NULL;
        if (key < node->key) {
            node->left = remove(node->key, key);
            return node;
        } else if (key > node->key) {
            node->right = remove(node->right, key);
            return node;
        } else { // key == root->key
            if (node->left == NULL) {
                Node *rightNode = node->right;
                delete node;
                count --;
                return rightNode;
            }

            if (node->right == NULL) {
                Node *leftNode = node->left;
                delete node;
                count --;
                return leftNode;
            }

            // 找到比待删除节点大的最小节点, 即待删除节点右子树的最小节点
            // 用这个节点顶替待删除节点的位置
            Node *successor = new Node(minimum(node->right));
            count ++;

            successor->right = removeMin(node->right);
            successor->left = node->left;

            delete node;
            count --;

            return successor;
        }
    }
};

#endif //BINARYSEARCHDEMO_BST_H
